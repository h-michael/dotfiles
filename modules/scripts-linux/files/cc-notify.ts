#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Unified Claude Code notification script for Linux

import { parseArgs } from "jsr:@std/cli/parse-args";

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

async function getAvailableSounds(): Promise<string[]> {
  const soundsDirs = [
    "/usr/share/sounds/freedesktop/stereo",
    "/run/current-system/sw/share/sounds/freedesktop/stereo",
  ];

  const sounds: Set<string> = new Set();

  for (const dir of soundsDirs) {
    try {
      for await (const entry of Deno.readDir(dir)) {
        if (entry.isFile && entry.name.endsWith(".oga")) {
          sounds.add(entry.name.replace(/\.oga$/, ""));
        }
      }
    } catch {
      // Directory doesn't exist or not readable
    }
  }

  return [...sounds].sort();
}

function usage(availableSounds: string[]): void {
  console.log(`Usage: cc-notify TITLE [OPTIONS]

Arguments:
  TITLE                Notification title (required, first argument)

Options:
  -s, --subtitle TEXT  Notification subtitle
  -m, --message TEXT   Notification message
  -S, --sound SOUND    Notification sound (without .oga extension)
  -a, --activate ID    App class to activate on click
  -h, --help           Show this help message

Available sounds:`);

  if (availableSounds.length > 0) {
    for (const sound of availableSounds) {
      console.log(`  ${sound}`);
    }
  } else {
    console.log("  No sounds found");
  }

  Deno.exit(1);
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
  const soundPath = `/run/current-system/sw/share/sounds/freedesktop/stereo/${sound}.oga`;
  // Fire and forget - don't wait for sound to finish
  runCommand(["pw-play", soundPath], { stdout: "null" });
}

async function sendNotification(title: string, message: string): Promise<void> {
  // Fire and forget - don't wait for action (notify-send --action blocks)
  const command = new Deno.Command("notify-send", {
    args: ["-a", "Claude Code", title, message],
    stdout: "null",
    stderr: "null",
  });
  command.spawn();
}

async function focusTerminal(terminalClass: string): Promise<void> {
  await runCommand([
    "hyprctl",
    "dispatch",
    "focuswindow",
    `class:${terminalClass}`,
  ]);
}

async function main(): Promise<void> {
  const args = parseArgs(Deno.args, {
    string: ["subtitle", "message", "sound", "activate"],
    boolean: ["help"],
    alias: {
      s: "subtitle",
      m: "message",
      S: "sound",
      a: "activate",
      h: "help",
    },
  });

  const availableSounds = await getAvailableSounds();

  if (args.help) {
    usage(availableSounds);
  }

  const positional = args._ as string[];
  if (positional.length === 0) {
    console.error("Error: TITLE is required");
    usage(availableSounds);
  }

  const title = String(positional[0]);
  const subtitle = args.subtitle || "";
  const message = args.message || "";
  let sound = args.sound || "";
  const activate = args.activate || TERMINAL_CLASS;

  // Build display title with subtitle
  let displayTitle = title;
  if (subtitle) {
    displayTitle = `${title} - ${subtitle}`;
  }

  // Check if terminal is active
  const activeClass = await getActiveWindowClass();

  // Auto-set sound based on active window if not explicitly provided
  if (!sound && activeClass !== activate) {
    sound = "message";
  }

  // Validate sound if provided
  if (sound && !availableSounds.includes(sound)) {
    console.error(`Warning: Sound '${sound}' may not be available.`);
  }

  // Play sound only if terminal is not active
  if (sound && activeClass !== activate) {
    await playSound(sound);
  }

  // Send notification (fire and forget)
  await sendNotification(displayTitle, message);
}

main();
