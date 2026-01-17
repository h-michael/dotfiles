#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Claude Code statusline for Deno - Self-contained version
// Features: directory, model, git status, code changes, output style,
// context window, tokens (input/output/cache), cost, block timer, session ID, execution time

// deno-types: https://deno.land/std/types.d.ts
// @ts-types https://deno.land/std/types.d.ts

interface ContextWindow {
  used_percentage?: number;
  remaining_percentage?: number;
  total_input_tokens?: number;
  current_usage?: {
    input_tokens?: number;
    output_tokens?: number;
    cache_creation_tokens?: number;
    cache_read_tokens?: number;
  };
}

interface StatusLineInput {
  model?: { display_name?: string };
  workspace?: { current_dir?: string; project_dir?: string };
  output_style?: { name?: string };
  session_id?: string;
  cost?: {
    total_cost_usd?: number;
    total_lines_added?: number;
    total_lines_removed?: number;
    total_tokens?: number;
  };
  transcript_path?: string;
  context_window?: ContextWindow;
  exceeds_200k_tokens?: boolean;
}

// Tokyo Night color scheme (truecolor)
const colors = {
  blue: "\x1b[38;2;122;170;247m",      // 7aa2f7
  cyan: "\x1b[38;2;125;207;255m",      // 7dcfff
  magenta: "\x1b[38;2;187;154;247m",   // bb9af7
  yellow: "\x1b[38;2;224;175;104m",    // e0af68
  green: "\x1b[38;2;158;206;106m",     // 9ece6a
  red: "\x1b[38;2;247;118;142m",       // f7768e
  orange: "\x1b[38;2;255;158;100m",    // ff9e64
  white: "\x1b[38;2;192;202;245m",     // c0caf5
  gray: "\x1b[38;2;139;148;191m",      // 8b94bf (lighter gray)
  reset: "\x1b[0m",
  blink: "\x1b[5m",
};

// Helper functions (replacing Fish functions)

// Format directory name display
function formatDirectory(currentDir: string, depth: number = 0): string | null {
  if (!currentDir) return null;

  if (depth <= 0) {
    return currentDir;
  }

  const pathParts = currentDir.split("/").filter((p) => p);
  const numParts = pathParts.length;

  if (depth >= numParts) {
    return currentDir;
  }

  const startIdx = numParts - depth;
  const dirName = pathParts.slice(startIdx).join("/");

  const home = Deno.env.get("HOME") || "";
  if (home && currentDir.startsWith(home + "/")) {
    const reconstructedPath = `${home}/${dirName}`;
    if (reconstructedPath === currentDir) {
      return `~/${dirName}`;
    }
  }

  return `⋯/${dirName}`;
}

// Format model display name
function formatModel(modelDisplay: string): string | null {
  if (!modelDisplay || modelDisplay === "null") return null;
  return modelDisplay.replace("Claude ", "").replace(/ /g, "-");
}

// Get git branch and status
async function getGitStatus(currentDir: string): Promise<string | null> {
  if (!currentDir) return null;

  try {
    const gitCheckCmd = new Deno.Command("git", {
      args: ["-C", currentDir, "rev-parse", "--git-dir"],
      stderr: "null",
      stdout: "null",
    });
    const result = await gitCheckCmd.output();
    if (!result.success) return null;

    const branchCmd = new Deno.Command("git", {
      args: ["-C", currentDir, "branch", "--show-current"],
    });
    const { stdout: branchOutput } = await branchCmd.output();
    let branch = new TextDecoder().decode(branchOutput).trim();
    if (!branch) branch = "detached";

    const statusCmd = new Deno.Command("git", {
      args: ["-C", currentDir, "status", "--porcelain"],
    });
    const { stdout: statusOutput } = await statusCmd.output();
    const status = new TextDecoder().decode(statusOutput);

    if (!status) return `on ${branch}`;

    const lines = status.split("\n").filter((l) => l);
    const staged = lines.filter((l) => /^[MADRCU]/.test(l)).length;
    const modified = lines.filter((l) => /^.[MD]/.test(l)).length;
    const untracked = lines.filter((l) => l.startsWith("??")).length;

    const indicators: string[] = [];
    if (staged > 0) indicators.push("+");
    if (modified > 0) indicators.push("!");
    if (untracked > 0) indicators.push("?");

    if (indicators.length > 0) {
      return `on ${branch} [${indicators.join("")}]`;
    }

    return `on ${branch}`;
  } catch {
    return null;
  }
}

// Format output style
function formatOutputStyle(style: string): string | null {
  if (!style || style === "null") return null;
  return style;
}

// Format cost
function formatCost(totalCost: number): string | null {
  const threshold = 0.01;
  if (totalCost < threshold) return null;
  return `$${totalCost.toFixed(3)}`;
}

// Format token count
function formatTokenCount(count: number): string {
  if (count >= 1_000_000) {
    return `${(count / 1_000_000).toFixed(1)}M`;
  } else if (count >= 1_000) {
    return `${Math.round(count / 1_000)}k`;
  }
  return count.toString();
}

// Format execution time
function formatTimer(startTimeMs: number): string | null {
  const elapsed = Date.now() - startTimeMs;
  if (elapsed <= 0) return null;
  return `${elapsed}ms`;
}

// Parse timestamp and get elapsed time in block
function getBlockTimerDisplay(timestamp: string): string | null {
  if (!timestamp) return null;

  try {
    const firstDate = new Date(timestamp.substring(0, 19));
    const currentDate = new Date();
    const elapsedSeconds = Math.floor(
      (currentDate.getTime() - firstDate.getTime()) / 1000,
    );
    const totalHours = elapsedSeconds / 3600;
    const blockNum = Math.floor(totalHours / 5);
    const blockStartHours = blockNum * 5;
    const elapsedInBlock = totalHours - blockStartHours;

    if (elapsedInBlock < 0) return null;

    const progressChars = Math.floor((elapsedInBlock / 5.0) * 16);
    const bar = "█".repeat(progressChars);
    const empty = "░".repeat(16 - progressChars);

    return `[${bar}${empty}] ${elapsedInBlock.toFixed(1)}h`;
  } catch {
    return null;
  }
}

// Format session ID (short display)
function formatSessionId(sessionId: string): string | null {
  if (!sessionId || sessionId === "null") return null;
  const shortId = sessionId.substring(0, 8);
  return `sid:${shortId}`;
}

// Format context window with warnings
function formatContextWindow(
  usedPct: number,
  exceedsLimit: boolean,
): string | null {
  if (usedPct <= 0 && !exceedsLimit) return null;

  const usedInt = Math.round(usedPct);
  let color = colors.gray;

  if (exceedsLimit) {
    color = colors.blink + colors.red;
  } else if (usedInt >= 90) {
    color = colors.red;
  } else if (usedInt >= 80) {
    color = colors.orange;
  } else if (usedInt >= 60) {
    color = colors.yellow;
  }

  return `${color}${usedInt}%${colors.reset}`;
}

// Main function
async function main() {
  const startTimeMs = Date.now();

  const decoder = new TextDecoder();
  const buffer = new Uint8Array(64 * 1024);
  const bytesRead = await Deno.stdin.read(buffer);
  const jsonStr = decoder.decode(buffer.slice(0, bytesRead || 0));

  let input: StatusLineInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    Deno.exit(1);
  }

  const parts: string[] = [];

  // Extract fields from JSON
  const modelDisplay = input.model?.display_name || "";
  const currentDir = input.workspace?.current_dir || "";
  const sessionId = input.session_id || "";
  const transcriptPath = input.transcript_path || "";
  const totalCost = input.cost?.total_cost_usd || 0;
  const contextUsedPct = input.context_window?.used_percentage ?? 0;
  const inputTokensCurrent =
    input.context_window?.current_usage?.input_tokens ?? 0;
  const outputTokensCurrent =
    input.context_window?.current_usage?.output_tokens ?? 0;
  const cacheReadTokens =
    input.context_window?.current_usage?.cache_read_tokens ?? 0;
  const exceedsLimit = input.exceeds_200k_tokens ?? false;

  // Directory
  const dirText = formatDirectory(currentDir, 3);
  if (dirText) {
    parts.push(`${colors.blue}${dirText}${colors.reset}`);
  }

  // Git
  const gitText = await getGitStatus(currentDir);
  if (gitText) {
    const branchMatch = gitText.match(/^on\s(.*?)(?:\s(\[.*\]))?$/);
    if (branchMatch) {
      const branch = branchMatch[1];
      const status = branchMatch[2];
      if (status) {
        parts.push(
          `${colors.gray}${branch}${colors.reset} ${colors.gray}${status}${colors.reset}`,
        );
      } else {
        parts.push(`${colors.gray}${branch}${colors.reset}`);
      }
    }
  }

  // Model
  const modelText = formatModel(modelDisplay);
  if (modelText) {
    parts.push(`${colors.gray}${modelText}${colors.reset}`);
  }

  // Output style (disabled by default, uncomment to enable)
  // const styleText = formatOutputStyle(outputStyle);
  // if (styleText) {
  //   parts.push(`${colors.yellow}🎨 ${styleText}${colors.reset}`);
  // }

  // Context window usage with warning
  const contextDisplay = formatContextWindow(contextUsedPct, exceedsLimit);
  if (contextDisplay) {
    parts.push(contextDisplay);
  }

  // Tokens (input, output, cache)
  if (inputTokensCurrent > 0 || outputTokensCurrent > 0 || cacheReadTokens > 0) {
    parts.push(`${colors.gray}in:${formatTokenCount(inputTokensCurrent)}${colors.reset}`);
    parts.push(`${colors.gray}out:${formatTokenCount(outputTokensCurrent)}${colors.reset}`);
    parts.push(`${colors.gray}cache:${formatTokenCount(cacheReadTokens)}${colors.reset}`);
  }

  // Cost
  const costText = formatCost(totalCost);
  if (costText) {
    parts.push(`${colors.gray}${costText}${colors.reset}`);
  }

  // Block timer (5-hour intervals)
  const blockTimerText = getBlockTimerDisplay(transcriptPath ? "2025-01-17" : "");
  if (blockTimerText) {
    parts.push(`${colors.gray}${blockTimerText}${colors.reset}`);
  }

  // Session ID (short display)
  const sessionIdText = formatSessionId(sessionId);
  if (sessionIdText) {
    parts.push(`${colors.gray}${sessionIdText}${colors.reset}`);
  }

  // Timer
  const timerText = formatTimer(startTimeMs);
  if (timerText) {
    parts.push(`${colors.gray}time:${timerText}${colors.reset}`);
  }

  // Output statusline
  console.log(parts.join(" "));
}

main().catch((err) => {
  console.error(err);
  Deno.exit(1);
});
