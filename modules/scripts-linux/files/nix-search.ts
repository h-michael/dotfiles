#!/usr/bin/env -S deno run --allow-run

interface SearchSite {
  name: string;
  buildUrl: (query: string) => string;
}

const sites: SearchSite[] = [
  {
    name: "Google",
    buildUrl: (q) => `https://www.google.com/search?q=${encodeURIComponent(q)}`,
  },
  {
    name: "NixOS Packages",
    buildUrl: (q) => `https://search.nixos.org/packages?query=${encodeURIComponent(q)}`,
  },
  {
    name: "NixOS Options",
    buildUrl: (q) => `https://search.nixos.org/options?query=${encodeURIComponent(q)}`,
  },
  {
    name: "MyNixOS",
    buildUrl: (q) => `https://mynixos.com/search?q=${encodeURIComponent(q)}`,
  },
  {
    name: "ArchWiki JP",
    buildUrl: (q) => `https://wiki.archlinux.jp/index.php?search=${encodeURIComponent(q)}`,
  },
  {
    name: "ArchWiki EN",
    buildUrl: (q) => `https://wiki.archlinux.org/index.php?search=${encodeURIComponent(q)}`,
  },
  {
    name: "AUR",
    buildUrl: (q) => `https://aur.archlinux.org/packages?O=0&K=${encodeURIComponent(q)}`,
  },
  {
    name: "Arch Packages",
    buildUrl: (q) => `https://archlinux.org/packages/?q=${encodeURIComponent(q)}`,
  },
];

async function rofiSelect(items: string[], prompt: string): Promise<string | null> {
  const cmd = new Deno.Command("rofi", {
    args: ["-dmenu", "-p", prompt, "-i", "-no-custom"],
    stdin: "piped",
    stdout: "piped",
  });

  const process = cmd.spawn();
  const writer = process.stdin.getWriter();
  await writer.write(new TextEncoder().encode(items.join("\n")));
  await writer.close();

  const { stdout, success } = await process.output();
  if (!success) return null;

  return new TextDecoder().decode(stdout).trim();
}

async function rofiInput(prompt: string): Promise<string | null> {
  const cmd = new Deno.Command("rofi", {
    args: ["-dmenu", "-p", prompt, "-l", "0"],
    stdout: "piped",
  });

  const { stdout, success } = await cmd.output();
  if (!success) return null;

  return new TextDecoder().decode(stdout).trim();
}

async function openBrowser(url: string): Promise<void> {
  const cmd = new Deno.Command("xdg-open", {
    args: [url],
    stdout: "null",
    stderr: "null",
  });
  cmd.spawn();
}

async function getDefaultBrowser(): Promise<string> {
  const cmd = new Deno.Command("xdg-settings", {
    args: ["get", "default-web-browser"],
    stdout: "piped",
    stderr: "null",
  });
  const { stdout, success } = await cmd.output();
  if (!success) return "firefox";
  return new TextDecoder().decode(stdout).trim();
}

async function focusBrowser(desktop: string): Promise<void> {
  let targetBrowser: string;
  if (desktop.includes("firefox")) {
    targetBrowser = "firefox";
  } else if (desktop.includes("chrome")) {
    targetBrowser = "chrome";
  } else if (desktop.includes("chromium")) {
    targetBrowser = "chromium";
  } else if (desktop.includes("brave")) {
    targetBrowser = "brave";
  } else {
    targetBrowser = desktop.replace(".desktop", "");
  }

  const cmd = new Deno.Command("hyprctl", {
    args: ["dispatch", "focuswindow", `class:^(?i).*${targetBrowser}.*$`],
    stdout: "null",
    stderr: "null",
  });
  await cmd.output();
}

const selected = await rofiSelect(
  sites.map((s) => s.name),
  "Search"
);
if (!selected) Deno.exit(0);

const site = sites.find((s) => s.name === selected);
if (!site) Deno.exit(1);

const query = await rofiInput("Query");
if (!query) Deno.exit(0);

await openBrowser(site.buildUrl(query));

await new Promise((resolve) => setTimeout(resolve, 500));

const browser = await getDefaultBrowser();
await focusBrowser(browser);
