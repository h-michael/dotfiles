#!/usr/bin/env -S deno run --allow-run

interface WaybarOutput {
  text: string;
  tooltip: string;
  percentage?: number;
}

async function getInternalBrightness(): Promise<WaybarOutput | null> {
  try {
    const listCmd = new Deno.Command("brightnessctl", {
      args: ["--list"],
      stdout: "piped",
      stderr: "piped",
    });
    const listOutput = await listCmd.output();
    const listText = new TextDecoder().decode(listOutput.stdout);

    if (!listText.includes("backlight")) {
      return null;
    }

    const getCmd = new Deno.Command("brightnessctl", {
      args: ["--machine-readable", "get"],
      stdout: "piped",
      stderr: "piped",
    });
    const getOutput = await getCmd.output();
    const brightness = parseInt(
      new TextDecoder().decode(getOutput.stdout).trim(),
    );

    const maxCmd = new Deno.Command("brightnessctl", {
      args: ["--machine-readable", "max"],
      stdout: "piped",
      stderr: "piped",
    });
    const maxOutput = await maxCmd.output();
    const max = parseInt(new TextDecoder().decode(maxOutput.stdout).trim());

    const percentage = Math.round((brightness / max) * 100);

    return {
      text: `☼ ${percentage}%`,
      tooltip: `Internal Display: ${percentage}%`,
      percentage,
    };
  } catch {
    return null;
  }
}

async function getExternalBrightness(): Promise<WaybarOutput | null> {
  try {
    const cmd = new Deno.Command("ddcutil", {
      args: ["getvcp", "10"],
      stdout: "piped",
      stderr: "piped",
    });
    const { stdout } = await cmd.output();
    const output = new TextDecoder().decode(stdout);

    const match = output.match(/current value =\s+(\d+), max value =\s+(\d+)/);
    if (!match) {
      return null;
    }

    const current = parseInt(match[1]);
    const max = parseInt(match[2]);
    const percentage = Math.round((current / max) * 100);

    return {
      text: `☼ ${percentage}%`,
      tooltip: `External Display: ${current}/${max} (${percentage}%)`,
      percentage,
    };
  } catch {
    return null;
  }
}

const internal = await getInternalBrightness();
if (internal) {
  console.log(JSON.stringify(internal));
} else {
  const external = await getExternalBrightness();
  if (external) {
    console.log(JSON.stringify(external));
  } else {
    console.log(JSON.stringify({ text: "☼ N/A", tooltip: "No display found" }));
  }
}
