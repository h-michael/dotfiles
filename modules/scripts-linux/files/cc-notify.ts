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
  -S, --sound SOUND    Notification sound (default: message)
  -q, --quiet          Always suppress sound
  --mute-when-active   Suppress sound only when terminal is active
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
  const isNiri = !!Deno.env.get("NIRI_SOCKET");

  if (isNiri) {
    const result = await runCommand(["niri", "msg", "--json", "focused-window"]);
    if (result.success && result.stdout) {
      try {
        const data = JSON.parse(result.stdout);
        return data.app_id || "";
      } catch {
        return "";
      }
    }
  } else {
    const result = await runCommand(["hyprctl", "activewindow", "-j"]);
    if (result.success && result.stdout) {
      try {
        const data = JSON.parse(result.stdout);
        return data.class || "";
      } catch {
        return "";
      }
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
  const isNiri = !!Deno.env.get("NIRI_SOCKET");

  if (isNiri) {
    // niri doesn't have a direct focus-by-app-id command;
    // use niri msg action focus-window (requires window ID)
    const result = await runCommand(["niri", "msg", "--json", "windows"]);
    if (result.success && result.stdout) {
      try {
        const windows = JSON.parse(result.stdout);
        const target = windows.find(
          (w: { app_id?: string }) => w.app_id === terminalClass,
        );
        if (target?.id !== undefined) {
          await runCommand([
            "niri",
            "msg",
            "action",
            "focus-window",
            "--id",
            String(target.id),
          ]);
        }
      } catch {
        // ignore parse errors
      }
    }
  } else {
    await runCommand([
      "hyprctl",
      "dispatch",
      "focuswindow",
      `class:${terminalClass}`,
    ]);
  }
}

async function main(): Promise<void> {
  const args = parseArgs(Deno.args, {
    string: ["subtitle", "message", "sound", "activate"],
    boolean: ["help", "quiet", "mute-when-active"],
    alias: {
      s: "subtitle",
      m: "message",
      S: "sound",
      q: "quiet",
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
  let sound = args.sound || "message";
  const quiet = args.quiet || false;
  const muteWhenActive = args["mute-when-active"] || false;
  const activate = args.activate || TERMINAL_CLASS;

  // Build display title with subtitle
  let displayTitle = title;
  if (subtitle) {
    displayTitle = `${title} - ${subtitle}`;
  }

  // Validate sound if provided
  if (sound && !availableSounds.includes(sound)) {
    console.error(`Warning: Sound '${sound}' may not be available.`);
  }

  // Always suppress sound when quiet mode is enabled
  if (quiet) {
    sound = "";
  }

  // Suppress sound when terminal is active and mute-when-active is enabled
  if (muteWhenActive && sound) {
    const activeClass = await getActiveWindowClass();
    if (activeClass === activate) {
      sound = "";
    }
  }

  // Play sound
  if (sound) {
    await playSound(sound);
  }

  // Send notification (fire and forget)
  await sendNotification(displayTitle, message);
}

main();
