#!/usr/bin/env -S deno run --allow-run
// Ergonomic reminder: encourage using C-[ instead of ESC

async function main(): Promise<void> {
  const message =
    "Ergonomic Reminder: For your health, use <C-[> instead of <ESC>!";

  // Try hyprctl notify first (Hyprland native)
  try {
    const hyprctl = new Deno.Command("hyprctl", {
      args: ["notify", "-1", "3000", "rgb(ff6b6b)", message],
      stdout: "null",
      stderr: "null",
    });
    const result = await hyprctl.output();
    if (result.success) {
      return;
    }
  } catch {
    // hyprctl not available
  }

  // Fallback to notify-send
  try {
    const notifySend = new Deno.Command("notify-send", {
      args: ["-t", "3000", "Ergonomic Reminder", message],
      stdout: "null",
      stderr: "null",
    });
    notifySend.spawn();
  } catch {
    // notify-send not available
  }
}

main();
