#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Claude Code statusline for Deno.
// Reads the JSON payload documented at
// https://code.claude.com/docs/en/statusline.md and prints one line.

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

// Resolve the current directory the way the docs recommend:
// prefer workspace.current_dir, fall back to cwd.
function resolveCwd(input: StatusLineInput): string {
  return input.workspace?.current_dir || input.cwd || "";
}

// Render the location as owner/repo[/subpath][ (worktree)] when the JSON
// exposes workspace.repo, otherwise ~/... or ⋯/last-three-segments.
function formatPath(input: StatusLineInput): string | null {
  const cwd = resolveCwd(input);
  if (!cwd) return null;

  const repo = input.workspace?.repo;
  const worktree = input.workspace?.git_worktree;

  if (repo?.name) {
    let display = repo.owner ? `${repo.owner}/${repo.name}` : repo.name;
    const anchor = `/${repo.name}`;
    const idx = cwd.lastIndexOf(anchor);
    if (idx >= 0) {
      const tail = cwd.slice(idx + anchor.length);
      if (tail && tail !== "/") display += tail;
    }
    if (worktree) display += ` (${worktree})`;
    return display;
  }

  const home = Deno.env.get("HOME") || "";
  if (home && cwd.startsWith(home + "/")) {
    return "~" + cwd.slice(home.length);
  }

  const parts = cwd.split("/").filter((p) => p);
  if (parts.length <= 3) return cwd;
  return "⋯/" + parts.slice(-3).join("/");
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

function formatTokenCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${Math.round(n / 1_000)}k`;
  return n.toString();
}

function formatContextPct(pct: number, exceeds: boolean): string | null {
  if (pct <= 0 && !exceeds) return null;
  const p = Math.round(pct);
  let color = colors.gray;
  if (exceeds) color = colors.blink + colors.red;
  else if (p >= 90) color = colors.red;
  else if (p >= 80) color = colors.orange;
  else if (p >= 60) color = colors.yellow;
  return paint(color, `ctx:${p}%`);
}

function formatDuration(seconds: number): string {
  if (seconds <= 0) return "0m";
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  return h > 0 ? `${h}h${m}m` : `${m}m`;
}

// Real 5-hour block indicator backed by rate_limits.five_hour.
// Bar shows used_percentage; the suffix shows time until resets_at.
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
  return paint(color, `#${pr.number}`);
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

  const parts: string[] = [];

  const pathText = formatPath(input);
  if (pathText) parts.push(paint(colors.blue, pathText));

  const gitText = await getGitStatus(resolveCwd(input));
  if (gitText) parts.push(paint(colors.gray, gitText));

  const modelText = formatModel(input.model?.display_name || "");
  if (modelText) parts.push(paint(colors.magenta, modelText));

  const effort = input.effort?.level;
  if (effort) parts.push(paint(colors.cyan, effort));

  if (input.agent?.name) parts.push(paint(colors.yellow, `@${input.agent.name}`));

  const ctxText = formatContextPct(
    input.context_window?.used_percentage ?? 0,
    input.exceeds_200k_tokens ?? false,
  );
  if (ctxText) parts.push(ctxText);

  const cu = input.context_window?.current_usage;
  if (cu) {
    const inTok = cu.input_tokens ?? 0;
    const outTok = cu.output_tokens ?? 0;
    const cacheTok = cu.cache_read_input_tokens ?? 0;
    if (inTok > 0 || outTok > 0 || cacheTok > 0) {
      parts.push(
        paint(
          colors.gray,
          `in:${formatTokenCount(inTok)} out:${formatTokenCount(outTok)} cache:${formatTokenCount(cacheTok)}`,
        ),
      );
    }
  }

  const costText = formatCost(input.cost?.total_cost_usd ?? 0);
  if (costText) parts.push(paint(colors.gray, costText));

  const blockText = formatFiveHourBlock(input.rate_limits?.five_hour);
  if (blockText) parts.push(blockText);

  if (input.session_name) parts.push(paint(colors.gray, `[${input.session_name}]`));

  const prText = formatPr(input.pr);
  if (prText) parts.push(prText);

  console.log(parts.join(" "));
}

main().catch((err) => {
  console.error(err);
  Deno.exit(1);
});
