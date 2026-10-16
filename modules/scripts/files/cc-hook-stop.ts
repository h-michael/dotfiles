#!/usr/bin/env bun
// Claude Code Stop hook - Generate enhanced message with project context
// Output: JSON { subtitle: string, message: string }

import { execFile } from "node:child_process";
import { readFile } from "node:fs/promises";
import { text } from "node:stream/consumers";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

interface StopHookInput {
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
  permission_mode?: string;
  hook_event_name?: string;
  stop_hook_active?: boolean;
}

interface Output {
  title: string;
  subtitle: string;
  message: string;
}

async function getRef(cwd: string): Promise<string | null> {
  try {
    await execFileAsync("git", ["rev-parse", "--git-dir"], { cwd });
    const { stdout } = await execFileAsync(
      "git",
      ["branch", "--show-current"],
      { cwd },
    ).catch(() => ({ stdout: "" }));
    const branch = stdout.trim();
    if (branch) return branch;
    return "detached";
  } catch {
    // Ignore errors
  }
  return null;
}

async function getLastTool(transcriptPath: string): Promise<string | null> {
  try {
    const content = await readFile(transcriptPath, "utf8");
    const lines = content.trim().split("\n").reverse();

    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.type === "tool_use" && entry.tool_name) {
          return entry.tool_name;
        }
        if (entry.message?.content) {
          for (const block of entry.message.content) {
            if (block.type === "tool_use" && block.name) {
              return block.name;
            }
          }
        }
      } catch {
        // Skip invalid JSON lines
      }
    }
  } catch {
    // File not found or not readable
  }
  return null;
}

async function main(): Promise<void> {
  const jsonStr = await text(process.stdin);

  let input: StopHookInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    process.exit(1);
  }

  // Prevent infinite loop - output nothing and exit
  if (input.stop_hook_active) {
    process.exit(0);
  }

  const cwd = input.cwd || process.cwd();
  const transcriptPath = input.transcript_path || "";
  const project = cwd.split("/").pop() || "unknown";

  // Gather context
  const ref = await getRef(cwd);
  const lastTool = await getLastTool(transcriptPath);

  // Build message
  const parts: string[] = [project];
  if (ref) parts[0] = `${project} (${ref})`;
  if (lastTool) parts.push(lastTool);

  const output: Output = {
    title: "Claude Code Stop",
    subtitle: "Done",
    message: parts.join(" | "),
  };

  console.log(JSON.stringify(output));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
