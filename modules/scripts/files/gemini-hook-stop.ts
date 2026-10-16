#!/usr/bin/env bun
// Gemini CLI AfterAgent hook - Send desktop notification on task completion
// Input: stdin JSON from gemini-cli AfterAgent event
// Output: stdout JSON {} (advisory hook, no control fields needed)

import { execFile, spawn } from "node:child_process";
import { readFile } from "node:fs/promises";
import { text } from "node:stream/consumers";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

interface AfterAgentInput {
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
  hook_event_name?: string;
  timestamp?: string;
  prompt?: string;
  prompt_response?: string;
  stop_hook_active?: boolean;
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

async function sendNotify(
  title: string,
  subtitle: string,
  message: string,
): Promise<void> {
  await new Promise<void>((resolve) => {
    const child = spawn(
      "cc-notify",
      [
        title,
        "-s",
        subtitle,
        "-m",
        message,
        "-a",
        "com.mitchellh.ghostty",
        "--mute-when-active",
      ],
      { stdio: ["ignore", "inherit", "inherit"] },
    );
    // cc-notify not available, skip
    child.on("error", () => resolve());
    child.on("close", () => resolve());
  });
}

async function main(): Promise<void> {
  const jsonStr = await text(process.stdin);

  let input: AfterAgentInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    console.log("{}");
    process.exit(0);
  }

  // Prevent infinite loop
  if (input.stop_hook_active) {
    console.log("{}");
    process.exit(0);
  }

  const cwd = input.cwd || process.env.GEMINI_CWD || process.cwd();
  const transcriptPath = input.transcript_path || "";
  const project = cwd.split("/").pop() || "unknown";

  const ref = await getRef(cwd);
  const lastTool = await getLastTool(transcriptPath);

  const parts: string[] = [project];
  if (ref) parts[0] = `${project} (${ref})`;
  if (lastTool) parts.push(lastTool);

  await sendNotify("Gemini CLI Stop", "Done", parts.join(" | "));

  console.log("{}");
}

main().catch((err) => {
  console.error(err);
  console.log("{}");
  process.exit(0);
});
