#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Unified Claude Code notification script

import { parseArgs } from "jsr:@std/cli/parse-args";

async function getAvailableSounds(): Promise<string[]> {
  const soundsDirs = [
    "/System/Library/Sounds",
    `${Deno.env.get("HOME")}/Library/Sounds`,
  ];

  const sounds: Set<string> = new Set();

  for (const dir of soundsDirs) {
    try {
      for await (const entry of Deno.readDir(dir)) {
        if (entry.isFile && entry.name.endsWith(".aiff")) {
          sounds.add(entry.name.replace(/\.aiff$/, ""));
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
  -S, --sound SOUND    Notification sound
  -a, --activate ID    App to activate on click
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

async function getFrontmostApp(): Promise<string> {
  try {
    const command = new Deno.Command("osascript", {
      args: [
        "-e",
        'tell application "System Events" to get name of first application process whose frontmost is true',
      ],
      stdout: "piped",
      stderr: "piped",
    });

    const { stdout } = await command.output();
    return new TextDecoder().decode(stdout).trim();
  } catch {
    return "";
  }
}

async function commandExists(cmd: string): Promise<boolean> {
  try {
    const command = new Deno.Command("which", {
      args: [cmd],
      stdout: "null",
      stderr: "null",
    });
    const { success } = await command.output();
    return success;
  } catch {
    return false;
  }
}

async function sendViaTerminalNotifier(
  title: string,
  subtitle: string,
  message: string,
  sound: string,
  activate: string,
): Promise<void> {
  const args = ["-title", title];

  if (subtitle) args.push("-subtitle", subtitle);
  if (message) args.push("-message", message);
  if (sound) args.push("-sound", sound);
  if (activate) args.push("-activate", activate);

  const command = new Deno.Command("terminal-notifier", {
    args,
    stdout: "inherit",
    stderr: "inherit",
  });

  await command.output();
}

async function sendViaOsascript(
  title: string,
  subtitle: string,
  message: string,
  sound: string,
): Promise<void> {
  let notificationText = title;
  if (subtitle) notificationText += ` - ${subtitle}`;
  if (message) notificationText += `: ${message}`;

  let script = `display notification "${notificationText}"`;
  if (sound) script += ` sound name "${sound}"`;

  const command = new Deno.Command("osascript", {
    args: ["-e", script],
    stdout: "inherit",
    stderr: "inherit",
  });

  await command.output();
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
  const activate = args.activate || "";

  // Validate sound if provided
  if (sound && !availableSounds.includes(sound)) {
    console.error(`Error: Sound '${sound}' is not available.`);
    console.error("Available sounds:");
    for (const s of availableSounds) {
      console.error(`  ${s}`);
    }
    Deno.exit(1);
  }

  // Check if Ghostty is the frontmost application
  const frontmostApp = await getFrontmostApp();

  // Auto-set sound based on frontmost app if not explicitly provided
  if (!sound && frontmostApp.toLowerCase() !== "ghostty") {
    sound = "Hero";
  }

  // Try terminal-notifier first, fallback to osascript
  if (await commandExists("terminal-notifier")) {
    await sendViaTerminalNotifier(title, subtitle, message, sound, activate);
  } else {
    await sendViaOsascript(title, subtitle, message, sound);
  }
}

main();
