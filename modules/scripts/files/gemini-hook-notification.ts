#!/usr/bin/env bun
// Gemini CLI Notification hook - Send desktop notification with project context
// Input: stdin JSON from gemini-cli Notification event
// Output: stdout JSON {} (advisory hook, no control fields needed)

import { execFile, spawn } from "node:child_process";
import { text } from "node:stream/consumers";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

interface NotificationHookInput {
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
  hook_event_name?: string;
  timestamp?: string;
  notification_type?: string;
  message?: string;
  details?: Record<string, unknown>;
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

function getSubtitle(notificationType: string): string {
  switch (notificationType) {
    case "ToolPermission":
      return "Permission";
    default:
      return "Notification";
  }
}

async function sendNotify(
  title: string,
  subtitle: string,
  message: string,
): Promise<void> {
  await new Promise<void>((resolve) => {
    const child = spawn(
      "cc-notify",
      [title, "-s", subtitle, "-m", message, "-a", "com.mitchellh.ghostty"],
      { stdio: ["ignore", "inherit", "inherit"] },
    );
    // cc-notify not available, skip
    child.on("error", () => resolve());
    child.on("close", () => resolve());
  });
}

async function main(): Promise<void> {
  const jsonStr = await text(process.stdin);

  let input: NotificationHookInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    console.log("{}");
    process.exit(0);
  }

  const cwd = input.cwd || process.env.GEMINI_CWD || process.cwd();
  const originalMessage = input.message || "";
  const notificationType = input.notification_type || "";
  const project = cwd.split("/").pop() || "unknown";

  const ref = await getRef(cwd);

  let projectId = project;
  if (ref) projectId = `${project} (${ref})`;

  const message = `${projectId} - ${originalMessage}`;
  const subtitle = getSubtitle(notificationType);

  await sendNotify("Gemini CLI Notification", subtitle, message);

  console.log("{}");
}

main().catch((err) => {
  console.error(err);
  console.log("{}");
  process.exit(0);
});
