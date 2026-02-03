#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Claude Code Stop hook - Generate enhanced message with project context
// Output: JSON { subtitle: string, message: string }

interface StopHookInput {
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
  permission_mode?: string;
  hook_event_name?: string;
  stop_hook_active?: boolean;
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

async function getLastTool(transcriptPath: string): Promise<string | null> {
  try {
    const content = await Deno.readTextFile(transcriptPath);
    const lines = content.trim().split("\n").reverse();

    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.type === "tool_use" && entry.tool_name) {
          return entry.tool_name;
        }
        if (entry.message?.content) {
          for (const block of entry.message.content) {
            if (block.type === "tool_use" && block.name) {
              return block.name;
            }
          }
        }
      } catch {
        // Skip invalid JSON lines
      }
    }
  } catch {
    // File not found or not readable
  }
  return null;
}

async function main(): Promise<void> {
  const decoder = new TextDecoder();
  const buffer = new Uint8Array(64 * 1024);
  const bytesRead = await Deno.stdin.read(buffer);
  const jsonStr = decoder.decode(buffer.slice(0, bytesRead || 0));

  let input: StopHookInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    Deno.exit(1);
  }

  // Prevent infinite loop - output nothing and exit
  if (input.stop_hook_active) {
    Deno.exit(0);
  }

  const cwd = input.cwd || Deno.cwd();
  const transcriptPath = input.transcript_path || "";
  const project = cwd.split("/").pop() || "unknown";

  // Gather context
  const ref = await getRef(cwd);
  const lastTool = await getLastTool(transcriptPath);

  // Build message
  const parts: string[] = [project];
  if (ref) parts[0] = `${project} (${ref})`;
  if (lastTool) parts.push(lastTool);

  const output: Output = {
    title: "Claude Code Stop",
    subtitle: "Done",
    message: parts.join(" | "),
  };

  console.log(JSON.stringify(output));
}

main().catch((err) => {
  console.error(err);
  Deno.exit(1);
});
