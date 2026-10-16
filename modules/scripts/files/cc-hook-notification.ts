#!/usr/bin/env bun
// Claude Code Notification hook - Generate enhanced message with project context
// Output: JSON { subtitle: string, message: string }

import { execFile } from "node:child_process";
import { text } from "node:stream/consumers";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

interface NotificationHookInput {
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
  permission_mode?: string;
  hook_event_name?: string;
  message?: string;
  title?: string;
  notification_type?: string;
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

function getSubtitle(notificationType: string, title: string): string {
  switch (notificationType) {
    case "permission_prompt":
      return "Permission";
    case "idle_prompt":
      return "Waiting";
    case "auth_success":
      return "Auth";
    case "elicitation_dialog":
      return "Question";
    default:
      return title || "Notification";
  }
}

async function main(): Promise<void> {
  const jsonStr = await text(process.stdin);

  let input: NotificationHookInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    process.exit(1);
  }

  const cwd = input.cwd || process.cwd();
  const originalMessage = input.message || "";
  const title = input.title || "";
  const notificationType = input.notification_type || "";
  const project = cwd.split("/").pop() || "unknown";

  // Gather context
  const ref = await getRef(cwd);

  // Build project identifier (use parentheses like Stop hook)
  let projectId = project;
  if (ref) projectId = `${project} (${ref})`;

  // Build message (avoid [] as terminal-notifier has issues with brackets)
  const message = `${projectId} - ${originalMessage}`;

  // Get appropriate subtitle
  const subtitle = getSubtitle(notificationType, title);

  const output: Output = {
    title: "Claude Code Notification",
    subtitle,
    message,
  };

  console.log(JSON.stringify(output));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
