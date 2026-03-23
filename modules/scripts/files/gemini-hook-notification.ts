#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Gemini CLI Notification hook - Send desktop notification with project context
// Input: stdin JSON from gemini-cli Notification event
// Output: stdout JSON {} (advisory hook, no control fields needed)

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
  try {
    const command = new Deno.Command("cc-notify", {
      args: [
        title,
        "-s",
        subtitle,
        "-m",
        message,
        "-a",
        "com.mitchellh.ghostty",
      ],
      stdout: "inherit",
      stderr: "inherit",
    });
    await command.output();
  } catch {
    // cc-notify not available, skip
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
    console.log("{}");
    Deno.exit(0);
  }

  const cwd = input.cwd || Deno.env.get("GEMINI_CWD") || Deno.cwd();
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
  Deno.exit(0);
});
