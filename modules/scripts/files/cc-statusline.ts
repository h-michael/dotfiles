#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Claude Code statusline for Deno.
// Reads the JSON payload documented at
// https://code.claude.com/docs/en/statusline.md and prints one or two lines.

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
}

// Tokyo Night truecolor palette.
const colors = {
  blue: "\x1b[38;2;122;170;247m",
  cyan: "\x1b[38;2;125;207;255m",
  magenta: "\x1b[38;2;187;154;247m",
  yellow: "\x1b[38;2;224;175;104m",
  green: "\x1b[38;2;158;206;106m",
  red: "\x1b[38;2;247;118;142m",
  orange: "\x1b[38;2;255;158;100m",
  white: "\x1b[38;2;192;202;245m",
  gray: "\x1b[38;2;139;148;191m",
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

function visibleLength(s: string): number {
  return [...stripAnsi(s)].length;
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

  const home = Deno.env.get("HOME") || "";
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
    const out = await new Deno.Command("git", {
      args: ["status", "--branch", "--porcelain=v1"],
      cwd,
      stderr: "null",
    }).output();
    if (!out.success) return null;

    const text = new TextDecoder().decode(out.stdout);
    const lines = text.split("\n");
    const first = lines[0] || "";
    let branch = "detached";
    if (first.startsWith("## ")) {
      const rest = first.slice(3);
      if (rest.startsWith("HEAD (no branch)")) {
        branch = "detached";
      } else {
        const upstreamIdx = rest.indexOf("...");
        branch = upstreamIdx >= 0 ? rest.slice(0, upstreamIdx) : rest.split(" ")[0];
      }
    }

    const entries = lines.slice(1).filter((l) => l);
    const staged = entries.some((l) => /^[MADRCU]/.test(l));
    const modified = entries.some((l) => /^.[MD]/.test(l));
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
  return `$${v.toFixed(3)}`;
}

function formatLinesChanged(added: number, removed: number): string | null {
  if (added <= 0 && removed <= 0) return null;
  return `${paint(colors.green, `+${added}`)}/${paint(colors.red, `-${removed}`)}`;
}

function formatTokenCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${Math.round(n / 1_000)}k`;
  return n.toString();
}

// Suffix like "/1M" only when the model isn't on the default 200k window.
function formatContextSize(size?: number): string {
  if (!size || size <= 200_000) return "";
  if (size >= 1_000_000) return "/1M";
  return `/${Math.round(size / 1000)}k`;
}

function formatContextPct(
  pct: number,
  exceeds: boolean,
  size?: number,
): string | null {
  if (pct <= 0 && !exceeds) return null;
  const p = Math.round(pct);
  let color = colors.gray;
  if (exceeds) color = colors.blink + colors.red;
  else if (p >= 90) color = colors.red;
  else if (p >= 80) color = colors.orange;
  else if (p >= 60) color = colors.yellow;
  return paint(color, `ctx:${p}%${formatContextSize(size)}`);
}

function formatDuration(seconds: number): string {
  if (seconds <= 0) return "0m";
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  return h > 0 ? `${h}h${m}m` : `${m}m`;
}

function formatFiveHourBlock(rl: RateLimitWindow | undefined): string | null {
  if (!rl) return null;
  const pct = rl.used_percentage;
  const resetsAt = rl.resets_at;
  if (pct == null && resetsAt == null) return null;

  const segments: string[] = [];
  if (pct != null) {
    const p = Math.round(pct);
    const width = 10;
    const filled = Math.min(width, Math.max(0, Math.floor((p / 100) * width)));
    const bar = "█".repeat(filled) + "░".repeat(width - filled);

    let color = colors.gray;
    if (p >= 90) color = colors.red;
    else if (p >= 75) color = colors.orange;
    else if (p >= 50) color = colors.yellow;

    segments.push(paint(color, `5h[${bar}] ${p}%`));
  }
  if (resetsAt != null) {
    const remaining = resetsAt - Math.floor(Date.now() / 1000);
    if (remaining > 0) {
      segments.push(paint(colors.gray, `⟳${formatDuration(remaining)}`));
    }
  }
  return segments.join(" ");
}

// Only render 7-day usage once it crosses 75% — otherwise it's noise.
function formatSevenDay(rl: RateLimitWindow | undefined): string | null {
  if (!rl || rl.used_percentage == null) return null;
  const p = Math.round(rl.used_percentage);
  if (p < 75) return null;

  let color = colors.yellow;
  if (p >= 90) color = colors.red;
  else if (p >= 80) color = colors.orange;

  const segments = [paint(color, `7d:${p}%`)];
  if (rl.resets_at) {
    const remaining = rl.resets_at - Math.floor(Date.now() / 1000);
    if (remaining > 0) {
      segments.push(paint(colors.gray, `⟳${formatDuration(remaining)}`));
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

async function main() {
  const buf = new Uint8Array(64 * 1024);
  const n = await Deno.stdin.read(buf);
  const raw = new TextDecoder().decode(buf.slice(0, n || 0));

  let input: StatusLineInput = {};
  try {
    input = JSON.parse(raw);
  } catch {
    console.error("Failed to parse input JSON");
    Deno.exit(1);
  }

  const cols = parseInt(Deno.env.get("COLUMNS") || "0", 10) || 200;

  const paths = pathVariants(input);
  const gitText = await getGitStatus(resolveCwd(input));

  const modelText = formatModel(input.model?.display_name || "");
  const effort = input.effort?.level;
  const agentName = input.agent?.name;

  const ctxText = formatContextPct(
    input.context_window?.used_percentage ?? 0,
    input.exceeds_200k_tokens ?? false,
    input.context_window?.context_window_size,
  );

  const cu = input.context_window?.current_usage;
  let tokensText: string | null = null;
  if (cu) {
    const inTok = cu.input_tokens ?? 0;
    const outTok = cu.output_tokens ?? 0;
    const cacheTok = cu.cache_read_input_tokens ?? 0;
    if (inTok > 0 || outTok > 0 || cacheTok > 0) {
      tokensText = paint(
        colors.gray,
        `in:${formatTokenCount(inTok)} out:${formatTokenCount(outTok)} cache:${formatTokenCount(cacheTok)}`,
      );
    }
  }

  const costText = formatCost(input.cost?.total_cost_usd ?? 0);
  const linesText = formatLinesChanged(
    input.cost?.total_lines_added ?? 0,
    input.cost?.total_lines_removed ?? 0,
  );

  const block5h = formatFiveHourBlock(input.rate_limits?.five_hour);
  const block7d = formatSevenDay(input.rate_limits?.seven_day);
  const prText = formatPr(input.pr);
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
    return items.join(" ");
  };

  // Try each path variant in order and stop once line 1 fits COLUMNS.
  let line1 = buildLine1(paths[0] || "");
  for (let i = 1; i < paths.length && visibleLength(line1) > cols; i++) {
    line1 = buildLine1(paths[i]);
  }

  // Line 2: execution context and usage — what's running and how much it costs.
  const line2Items: string[] = [];
  if (modelText) line2Items.push(paint(colors.magenta, modelText));
  if (effort) line2Items.push(paint(colors.cyan, effort));
  if (agentName) line2Items.push(paint(colors.yellow, `@${agentName}`));
  if (ctxText) line2Items.push(ctxText);
  if (tokensText) line2Items.push(tokensText);
  if (costText) line2Items.push(paint(colors.gray, costText));
  if (block5h) line2Items.push(block5h);
  if (block7d) line2Items.push(block7d);

  console.log(line1);
  if (line2Items.length) console.log(line2Items.join(" "));
}

main().catch((err) => {
  console.error(err);
  Deno.exit(1);
});
