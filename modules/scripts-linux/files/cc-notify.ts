#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env

/**
 * Send Claude Code notification with click action and sound
 * Usage: claude_code_notify.ts <title> <message> [sound] [transcript_path] [cwd]
 */

const TERMINAL_CLASS = "com.mitchellh.ghostty";

async function runCommand(
  cmd: string[],
  options?: { stdout?: "piped" | "inherit" | "null" },
): Promise<{ success: boolean; stdout?: string }> {
  try {
    const command = new Deno.Command(cmd[0], {
      args: cmd.slice(1),
      stdout: options?.stdout ?? "piped",
      stderr: "null",
    });
    const result = await command.output();
    return {
      success: result.success,
      stdout: result.stdout
        ? new TextDecoder().decode(result.stdout).trim()
        : undefined,
    };
  } catch {
    return { success: false };
  }
}

async function getProjectName(
  transcriptPath?: string,
  cwd?: string,
): Promise<string> {
  if (transcriptPath) {
    try {
      const content = await Deno.readTextFile(transcriptPath);
      const lines = content
        .trim()
        .split("\n")
        .filter((l) => l);
      if (lines.length > 0) {
        const lastLine = JSON.parse(lines[lines.length - 1]);
        if (lastLine.cwd) {
          return lastLine.cwd.split("/").pop() || "";
        }
      }
    } catch {
      // Ignore errors reading transcript
    }
  }

  if (cwd) {
    return cwd.split("/").pop() || "";
  }

  return "";
}

async function getActiveWindowClass(): Promise<string> {
  const result = await runCommand(["hyprctl", "activewindow", "-j"]);
  if (result.success && result.stdout) {
    try {
      const data = JSON.parse(result.stdout);
      return data.class || "";
    } catch {
      return "";
    }
  }
  return "";
}

async function playSound(sound: string): Promise<void> {
  const soundPath = `/usr/share/sounds/freedesktop/stereo/${sound}`;
  // Fire and forget - don't wait for sound to finish
  runCommand(["pw-play", soundPath], { stdout: "null" });
}

async function sendNotification(
  title: string,
  message: string,
): Promise<string> {
  const result = await runCommand([
    "notify-send",
    "-a",
    "Claude Code",
    "--action=default=Focus",
    title,
    message,
  ]);
  return result.stdout || "";
}

async function focusTerminal(): Promise<void> {
  await runCommand([
    "hyprctl",
    "dispatch",
    "focuswindow",
    `class:${TERMINAL_CLASS}`,
  ]);
}

async function main(): Promise<void> {
  const args = Deno.args;

  let title = args[0] || "Claude Code";
  const message = args[1] || "Task completed";
  const sound = args[2] || "message.oga";
  const transcriptPath = args[3];
  const cwd = args[4];

  // Get project name and add to title
  const projectName = await getProjectName(transcriptPath, cwd);
  if (projectName) {
    title = `${title} - ${projectName}`;
  }

  // Check if terminal is active
  const activeClass = await getActiveWindowClass();

  // Play sound only if terminal is not active
  if (activeClass !== TERMINAL_CLASS) {
    await playSound(sound);
  }

  // Send notification and handle action
  const action = await sendNotification(title, message);

  if (action === "default") {
    await focusTerminal();
  }
}

main();
