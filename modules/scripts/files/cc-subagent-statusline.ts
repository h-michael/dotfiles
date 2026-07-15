#!/usr/bin/env -S deno run --allow-read --allow-env
// Claude Code subagent statusline for Deno.
// Reads the JSON payload documented at
// https://code.claude.com/docs/en/statusline.md#subagent-status-lines
// and writes one JSON line per row: {"id": "...", "content": "..."}.

interface Task {
  id: string;
  name?: string;
  type?: string;
  status?: string;
  description?: string;
  label?: string;
  startTime?: number;
  model?: string;
  contextWindowSize?: number;
  tokenCount?: number;
  tokenSamples?: number[];
  cwd?: string;
}

interface SubagentInput {
  columns?: number;
  tasks?: Task[];
  session_id?: string;
}

const colors = {
  cyan: "\x1b[38;2;125;207;255m",
  magenta: "\x1b[38;2;187;154;247m",
  yellow: "\x1b[38;2;224;175;104m",
  green: "\x1b[38;2;158;206;106m",
  red: "\x1b[38;2;247;118;142m",
  orange: "\x1b[38;2;255;158;100m",
  gray: "\x1b[38;2;139;148;191m",
  reset: "\x1b[0m",
};

function paint(color: string, text: string): string {
  return `${color}${text}${colors.reset}`;
}

function formatTokenCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${Math.round(n / 1_000)}k`;
  return n.toString();
}

// Map any status vocabulary the harness might use into a color.
function statusColor(status: string | undefined): string {
  switch (status) {
    case "in_progress":
    case "running":
    case "active":
      return colors.cyan;
    case "pending":
    case "queued":
    case "waiting":
      return colors.yellow;
    case "completed":
    case "done":
    case "finished":
      return colors.green;
    case "failed":
    case "error":
    case "cancelled":
      return colors.red;
    default:
      return colors.gray;
  }
}

function contextPctColor(pct: number): string {
  if (pct >= 90) return colors.red;
  if (pct >= 80) return colors.orange;
  if (pct >= 60) return colors.yellow;
  return colors.gray;
}

function renderTask(t: Task): string {
  const parts: string[] = [];

  const label = t.label || t.description || "";
  const name = t.name || t.type || "task";
  parts.push(
    label
      ? `${paint(colors.magenta, name)} ${paint(colors.gray, label)}`
      : paint(colors.magenta, name),
  );

  if (t.status) {
    parts.push(paint(statusColor(t.status), t.status));
  }

  if (
    t.tokenCount != null &&
    t.contextWindowSize &&
    t.contextWindowSize > 0
  ) {
    const pct = Math.round((t.tokenCount / t.contextWindowSize) * 100);
    parts.push(paint(contextPctColor(pct), `${pct}%`));
  } else if (t.tokenCount != null && t.tokenCount > 0) {
    parts.push(paint(colors.gray, formatTokenCount(t.tokenCount)));
  }

  return parts.join(" ");
}

async function main() {
  const buf = new Uint8Array(64 * 1024);
  const n = await Deno.stdin.read(buf);
  const raw = new TextDecoder().decode(buf.slice(0, n || 0));

  let input: SubagentInput = {};
  try {
    input = JSON.parse(raw);
  } catch {
    Deno.exit(1);
  }

  const tasks = input.tasks || [];
  for (const t of tasks) {
    if (!t.id) continue;
    const line = JSON.stringify({ id: t.id, content: renderTask(t) });
    console.log(line);
  }
}

main().catch(() => Deno.exit(1));
