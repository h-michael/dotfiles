#!/usr/bin/env -S deno run --allow-run

const action = Deno.args[0];

if (!action || !["up", "down"].includes(action)) {
  console.error("Usage: brightness.ts {up|down}");
  Deno.exit(1);
}

async function hasInternalDisplay(): Promise<boolean> {
  try {
    const cmd = new Deno.Command("brightnessctl", {
      args: ["--list"],
      stdout: "piped",
      stderr: "piped",
    });
    const { stdout } = await cmd.output();
    const output = new TextDecoder().decode(stdout);
    return output.includes("backlight");
  } catch {
    return false;
  }
}

async function adjustInternalBrightness(direction: string): Promise<void> {
  const change = direction === "up" ? "2%+" : "2%-";
  const cmd = new Deno.Command("brightnessctl", {
    args: ["set", change],
  });
  await cmd.output();
}

async function adjustExternalBrightness(direction: string): Promise<void> {
  const change = direction === "up" ? "+" : "-";
  const amount = "1";

  const cmd = new Deno.Command("ddcutil", {
    args: ["setvcp", "10", change, amount],
    stdout: "null",
    stderr: "null",
  });

  // Run in background to avoid blocking
  cmd.spawn();
}

if (await hasInternalDisplay()) {
  await adjustInternalBrightness(action);
} else {
  await adjustExternalBrightness(action);
}
