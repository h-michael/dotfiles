#!/usr/bin/env bun
// Claude Code statusline.
// Reads the JSON payload documented at
// https://code.claude.com/docs/en/statusline.md and prints one or two lines.

import { execFile } from "node:child_process";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { text } from "node:stream/consumers";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

interface CurrentUsage {
  input_tokens?: number;
  output_tokens?: number;
  cache_creation_input_tokens?: number;
  cache_read_input_tokens?: number;
}

interface ContextWindow {
  used_percentage?: number;
  remaining_percentage?: number;
  total_input_tokens?: number;
  total_output_tokens?: number;
  context_window_size?: number;
  current_usage?: CurrentUsage | null;
}

interface RateLimitWindow {
  used_percentage?: number;
  resets_at?: number;
}

interface PromptCache {
  warm?: boolean;
  caching_observed?: boolean;
  ttl?: string;
  expires_at?: number | null;
  hit_ratio?: number | null;
  last_miss_at?: number | null;
  last_miss_cause?: { causes?: string[] } | null;
}

interface StatusLineInput {
  cwd?: string;
  session_id?: string;
  session_name?: string;
  transcript_path?: string;
  version?: string;
  model?: { id?: string; display_name?: string };
  workspace?: {
    current_dir?: string;
    project_dir?: string;
    added_dirs?: string[];
    git_worktree?: string;
    repo?: { host?: string; owner?: string; name?: string };
  };
  output_style?: { name?: string };
  cost?: {
    total_cost_usd?: number;
    total_duration_ms?: number;
    total_api_duration_ms?: number;
    total_lines_added?: number;
    total_lines_removed?: number;
  };
  context_window?: ContextWindow;
  exceeds_200k_tokens?: boolean;
  effort?: { level?: string };
  thinking?: { enabled?: boolean };
  rate_limits?: {
    five_hour?: RateLimitWindow;
    seven_day?: RateLimitWindow;
  };
  agent?: { name?: string };
  pr?: { number?: number; url?: string; review_state?: string };
  prompt_cache?: PromptCache;
  vim?: { mode?: string };
}

// Tokyo Night truecolor palette.
const colors = {
  blue: "\x1b[38;2;122;162;247m",
  cyan: "\x1b[38;2;125;207;255m",
  magenta: "\x1b[38;2;187;154;247m",
  yellow: "\x1b[38;2;224;175;104m",
  green: "\x1b[38;2;158;206;106m",
  red: "\x1b[38;2;247;118;142m",
  orange: "\x1b[38;2;255;158;100m",
  white: "\x1b[38;2;192;202;245m",
  gray: "\x1b[38;2;139;148;191m",
  dim: "\x1b[38;2;86;95;137m",
  reset: "\x1b[0m",
  blink: "\x1b[5m",
};

function paint(color: string, text: string): string {
  return `${color}${text}${colors.reset}`;
}

// OSC 8 hyperlink escape — Cmd+click opens `url` in Ghostty/iTerm2/WezTerm/Kitty.
function osc8(text: string, url: string): string {
  return `\x1b]8;;${url}\x1b\\${text}\x1b]8;;\x1b\\`;
}

function stripAnsi(s: string): string {
  return s
    .replace(/\x1b\]8;;[^\x1b]*\x1b\\/g, "")
    .replace(/\x1b\[[0-9;]*m/g, "");
}

// Terminal columns, so wide (CJK) characters count as two.
function visibleLength(s: string): number {
  return Bun.stringWidth(stripAnsi(s));
}

function resolveCwd(input: StatusLineInput): string {
  return input.workspace?.current_dir || input.cwd || "";
}

// Multiple path renderings from full to compact, tried in order until one fits.
function pathVariants(input: StatusLineInput): string[] {
  const cwd = resolveCwd(input);
  if (!cwd) return [];

  const repo = input.workspace?.repo;
  const worktree = input.workspace?.git_worktree;
  const worktreeSuffix = worktree ? ` (${worktree})` : "";

  if (repo?.name) {
    const anchor = `/${repo.name}`;
    const idx = cwd.lastIndexOf(anchor);
    const subpath =
      idx >= 0 ? cwd.slice(idx + anchor.length).replace(/\/$/, "") : "";
    const subpathTail = subpath.split("/").filter(Boolean).pop();

    const full =
      `${repo.owner ? repo.owner + "/" : ""}${repo.name}${subpath}${worktreeSuffix}`;
    const mid = `${repo.name}${subpath}${worktreeSuffix}`;
    const compact =
      `${repo.name}${subpathTail ? "/…/" + subpathTail : ""}${worktreeSuffix}`;
    return [full, mid, compact];
  }

  const home = process.env.HOME || "";
  if (home && cwd.startsWith(home + "/")) {
    const rel = cwd.slice(home.length);
    const tail = rel.split("/").filter(Boolean).pop() || "";
    return ["~" + rel, "~/…/" + tail];
  }

  const parts = cwd.split("/").filter((p) => p);
  if (parts.length <= 3) return [cwd];
  return [
    "⋯/" + parts.slice(-3).join("/"),
    "⋯/" + parts.slice(-2).join("/"),
    "⋯/" + parts.slice(-1).join("/"),
  ];
}

function formatModel(displayName: string): string | null {
  if (!displayName || displayName === "null") return null;
  return displayName.replace("Claude ", "").replace(/ /g, "-");
}

// One `git status -b --porcelain=v1` call gives branch + working-tree state.
async function getGitStatus(cwd: string): Promise<string | null> {
  if (!cwd) return null;
  try {
    // execFile's default 1 MiB maxBuffer can overflow on repos with many
    // untracked files, which would hide the branch entirely.
    const { stdout } = await execFileAsync(
      "git",
      ["--no-optional-locks", "status", "--branch", "--porcelain=v1"],
      { cwd, maxBuffer: 64 * 1024 * 1024 },
    );
    const lines = stdout.split("\n");
    const first = lines[0] || "";
    let branch = "detached";
    if (first.startsWith("## ")) {
      const rest = first.slice(3);
      const unborn = rest.match(/^(?:No commits yet|Initial commit) on (\S+)/);
      if (rest.startsWith("HEAD (no branch)")) {
        branch = "detached";
      } else if (unborn) {
        branch = unborn[1];
      } else {
        const upstreamIdx = rest.indexOf("...");
        branch = upstreamIdx >= 0 ? rest.slice(0, upstreamIdx) : rest.split(" ")[0];
      }
    }

    const entries = lines.slice(1).filter((l) => l);
    const staged = entries.some((l) => /^[MADRCUT]/.test(l));
    const modified = entries.some((l) => /^.[MDT]/.test(l));
    const untracked = entries.some((l) => l.startsWith("??"));

    const marks: string[] = [];
    if (staged) marks.push("+");
    if (modified) marks.push("!");
    if (untracked) marks.push("?");

    return marks.length ? `${branch} [${marks.join("")}]` : branch;
  } catch {
    return null;
  }
}

function formatCost(v: number): string | null {
  if (v < 0.01) return null;
  return `$${v.toFixed(2)}`;
}

function formatLinesChanged(added: number, removed: number): string | null {
  if (added <= 0 && removed <= 0) return null;
  return `${paint(colors.green, `+${added}`)}/${paint(colors.red, `-${removed}`)}`;
}

// Suffix like "/1M" only when the model isn't on the default 200k window.
function formatContextSize(size?: number): string {
  if (!size || size <= 200_000) return "";
  if (size >= 1_000_000) return "/1M";
  return `/${Math.round(size / 1000)}k`;
}

function thresholdColor(p: number, warn: number, high: number, crit: number): string {
  if (p >= crit) return colors.red;
  if (p >= high) return colors.orange;
  if (p >= warn) return colors.yellow;
  return colors.white;
}

function formatContextPct(
  pct: number,
  exceeds: boolean,
  size?: number,
): string | null {
  if (pct <= 0 && !exceeds) return null;
  const p = Math.round(pct);
  const color = exceeds
    ? colors.blink + colors.red
    : thresholdColor(p, 60, 80, 90);
  return paint(color, `ctx:${p}%${formatContextSize(size)}`);
}

function formatDuration(seconds: number): string {
  if (seconds <= 0) return "0m";
  if (seconds < 60) return "<1m";
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (d > 0) return `${d}d${h}h`;
  return h > 0 ? `${h}h${m}m` : `${m}m`;
}

function formatRateLimit(
  name: string,
  rl: RateLimitWindow | undefined,
): string | null {
  if (!rl) return null;
  const pct = rl.used_percentage;
  const resetsAt = rl.resets_at;
  if (pct == null && resetsAt == null) return null;

  const segments: string[] = [];
  if (pct != null) {
    const p = Math.round(pct);
    segments.push(paint(thresholdColor(p, 50, 75, 90), `${name}:${p}%`));
  } else {
    segments.push(paint(colors.white, `${name}:`));
  }
  if (resetsAt != null) {
    const remaining = resetsAt - Math.floor(Date.now() / 1000);
    if (remaining > 0) {
      segments.push(paint(colors.gray, formatDuration(remaining)));
    }
  }
  return segments.join(" ");
}

function formatPr(pr: StatusLineInput["pr"]): string | null {
  if (!pr?.number) return null;
  let color = colors.gray;
  switch (pr.review_state) {
    case "approved":
      color = colors.green;
      break;
    case "changes_requested":
      color = colors.red;
      break;
    case "pending":
      color = colors.yellow;
      break;
    case "draft":
      color = colors.gray;
      break;
  }
  const painted = paint(color, `#${pr.number}`);
  return pr.url ? osc8(painted, pr.url) : painted;
}

// Keep a miss cause visible only briefly; the payload holds the last cause
// until the next miss, which could be hours later.
const MISS_CAUSE_WINDOW_SEC = 5 * 60;

function formatPromptCache(pc: PromptCache | undefined): string | null {
  if (!pc?.caching_observed) return null;
  const now = Math.floor(Date.now() / 1000);
  const segments: string[] = [];

  if (pc.hit_ratio != null) {
    const p = Math.round(pc.hit_ratio * 100);
    let color = colors.white;
    if (p < 50) color = colors.red;
    else if (p < 80) color = colors.yellow;
    segments.push(paint(color, `cache:${p}%`));
  } else {
    segments.push(paint(colors.white, "cache:"));
  }

  const causes = pc.last_miss_cause?.causes;
  if (
    causes?.length &&
    pc.last_miss_at != null &&
    now - pc.last_miss_at < MISS_CAUSE_WINDOW_SEC
  ) {
    segments.push(paint(colors.orange, `miss:${causes.join(",")}`));
  }

  return segments.join(" ");
}

const TTL_SECONDS: Record<string, number> = { "5m": 5 * 60, "1h": 60 * 60 };

// Colour by the fraction of the TTL left so the same rule works for both
// the 5m and 1h TTLs.
function formatCacheExpiry(pc: PromptCache | undefined): string | null {
  if (!pc?.caching_observed) return null;
  const now = Math.floor(Date.now() / 1000);
  const remaining = pc.expires_at != null ? pc.expires_at - now : 0;
  if (!pc.warm || remaining <= 0) return paint(colors.red, "cache expire:cold");

  const ttl = TTL_SECONDS[pc.ttl ?? ""];
  let color = colors.white;
  if (ttl) {
    const ratio = remaining / ttl;
    if (ratio < 0.1) color = colors.orange;
    else if (ratio < 0.25) color = colors.yellow;
  }
  return paint(color, `cache expire:${formatDuration(remaining)}`);
}

// Same colours as the lualine mode section under tokyonight-night
// (lua/lualine/themes/_tokyonight.lua): mode colour as background with
// the theme's `black` as foreground.
const vimModeBg: Record<string, string> = {
  NORMAL: "\x1b[48;2;122;162;247m",
  INSERT: "\x1b[48;2;158;206;106m",
  VISUAL: "\x1b[48;2;187;154;247m",
  "VISUAL LINE": "\x1b[48;2;187;154;247m",
};
const vimModeFg = "\x1b[38;2;21;22;30m";

function formatVimMode(mode: string | undefined): string | null {
  if (!mode) return null;
  const bg = vimModeBg[mode];
  if (!bg) return paint(colors.white, mode);
  return paint(bg + vimModeFg, ` ${mode} `);
}

// The session name other sessions use to message this one (shown by
// /list-agents) is not in the status line payload, whose `session_name` is
// the /rename title instead. Claude Code keeps it in
// <config dir>/sessions/<pid>.json next to the session id; this file format
// is undocumented, so any failure just hides the item.
async function getPeerSessionName(
  sessionId: string | undefined,
): Promise<string | null> {
  if (!sessionId) return null;
  const configDir =
    process.env.CLAUDE_CONFIG_DIR || join(process.env.HOME || "", ".claude");
  const dir = join(configDir, "sessions");
  try {
    const files = (await readdir(dir)).filter((f) => f.endsWith(".json"));
    for (const f of files) {
      try {
        const data = JSON.parse(await readFile(join(dir, f), "utf8"));
        if (data?.sessionId === sessionId && typeof data.name === "string") {
          return data.name;
        }
      } catch {
        // A session may rewrite or remove its file while we read it.
      }
    }
  } catch {
    return null;
  }
  return null;
}

async function main() {
  const raw = await text(process.stdin);

  let input: StatusLineInput = {};
  try {
    input = JSON.parse(raw);
  } catch {
    console.error("Failed to parse input JSON");
    process.exit(1);
  }

  const cols = parseInt(process.env.COLUMNS || "0", 10) || 200;

  const paths = pathVariants(input);
  const [gitText, peerSessionName] = await Promise.all([
    getGitStatus(resolveCwd(input)),
    getPeerSessionName(input.session_id),
  ]);

  const modelText = formatModel(input.model?.display_name || "");
  const effort = input.effort?.level;
  const agentName = input.agent?.name;

  // exceeds_200k_tokens uses a fixed 200k threshold, so on a 1M window it
  // fires at about 20% used; only treat it as full on windows of 200k or less.
  const ctxSize = input.context_window?.context_window_size;
  const ctxText = formatContextPct(
    input.context_window?.used_percentage ?? 0,
    (input.exceeds_200k_tokens ?? false) && (ctxSize ?? 0) <= 200_000,
    ctxSize,
  );

  const costText = formatCost(input.cost?.total_cost_usd ?? 0);
  const linesText = formatLinesChanged(
    input.cost?.total_lines_added ?? 0,
    input.cost?.total_lines_removed ?? 0,
  );

  const block5h = formatRateLimit("5h", input.rate_limits?.five_hour);
  const block7d = formatRateLimit("7d", input.rate_limits?.seven_day);
  const prText = formatPr(input.pr);
  const cacheText = formatPromptCache(input.prompt_cache);
  const cacheExpiryText = formatCacheExpiry(input.prompt_cache);
  const vimText = formatVimMode(input.vim?.mode);
  const sessionName = input.session_name
    ? paint(colors.gray, `[${input.session_name}]`)
    : null;
  const sessionIdText = input.session_id
    ? paint(colors.gray, `#${input.session_id.slice(0, 8)}`)
    : null;

  // Line 1: repo/session state — where you are and what changed.
  const buildLine1 = (pathText: string) => {
    const items: string[] = [paint(colors.blue, pathText)];
    if (gitText) items.push(paint(colors.gray, gitText));
    if (linesText) items.push(linesText);
    if (prText) items.push(prText);
    if (sessionName) items.push(sessionName);
    if (sessionIdText) items.push(sessionIdText);
    if (peerSessionName) items.push(paint(colors.gray, `peer:${peerSessionName}`));
    return items.join(" ");
  };

  // Try each path variant in order and stop once line 1 fits COLUMNS.
  let line1 = buildLine1(paths[0] || "");
  for (let i = 1; i < paths.length && visibleLength(line1) > cols; i++) {
    line1 = buildLine1(paths[i]);
  }

  // Line 2: execution context and usage — what's running and how much it costs.
  // `drop` orders what goes first when the row is wider than COLUMNS; the
  // model group is never dropped.
  const groups: { items: (string | null)[]; drop?: number }[] = [
    {
      items: [
        vimText,
        modelText ? paint(colors.magenta, modelText) : null,
        effort ? paint(colors.cyan, effort) : null,
        agentName ? paint(colors.yellow, `@${agentName}`) : null,
      ],
    },
    { items: [ctxText], drop: 6 },
    { items: [cacheText], drop: 3 },
    { items: [cacheExpiryText], drop: 2 },
    { items: [block5h], drop: 5 },
    { items: [block7d], drop: 4 },
    { items: [costText ? paint(colors.white, costText) : null], drop: 1 },
  ];
  const buildLine2 = (dropped: number) =>
    groups
      .filter((g) => g.drop == null || g.drop > dropped)
      .map((g) => g.items.filter(Boolean).join(" "))
      .filter(Boolean)
      .join(paint(colors.dim, " │ "));
  let line2 = buildLine2(0);
  for (let d = 1; d <= 6 && visibleLength(line2) > cols; d++) {
    line2 = buildLine2(d);
  }

  console.log(line1);
  if (line2) console.log(line2);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
