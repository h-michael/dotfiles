#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Claude Code Notification hook - Generate enhanced message with project context
// Output: JSON { subtitle: string, message: string }

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
    const gitCheck = new Deno.Command("git", {
      args: ["rev-parse", "--git-dir"],
      cwd,
      stdout: "null",
      stderr: "null",
    });
    const gitResult = await gitCheck.output();

    if (gitResult.success) {
      const gitBranch = new Deno.Command("git", {
        args: ["branch", "--show-current"],
        cwd,
        stdout: "piped",
        stderr: "null",
      });
      const { stdout } = await gitBranch.output();
      const branch = new TextDecoder().decode(stdout).trim();
      if (branch) return branch;
      return "detached";
    }
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
  const decoder = new TextDecoder();
  const buffer = new Uint8Array(64 * 1024);
  const bytesRead = await Deno.stdin.read(buffer);
  const jsonStr = decoder.decode(buffer.slice(0, bytesRead || 0));

  let input: NotificationHookInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    Deno.exit(1);
  }

  const cwd = input.cwd || Deno.cwd();
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
  Deno.exit(1);
});
