#!/usr/bin/env -S deno run --allow-run --allow-read --allow-env
// Gemini CLI AfterAgent hook - Send desktop notification on task completion
// Input: stdin JSON from gemini-cli AfterAgent event
// Output: stdout JSON {} (advisory hook, no control fields needed)

interface AfterAgentInput {
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
  hook_event_name?: string;
  timestamp?: string;
  prompt?: string;
  prompt_response?: string;
  stop_hook_active?: boolean;
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
        "--mute-when-active",
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

  let input: AfterAgentInput = {};
  try {
    input = JSON.parse(jsonStr);
  } catch {
    console.error("Failed to parse input JSON");
    console.log("{}");
    Deno.exit(0);
  }

  // Prevent infinite loop
  if (input.stop_hook_active) {
    console.log("{}");
    Deno.exit(0);
  }

  const cwd = input.cwd || Deno.env.get("GEMINI_CWD") || Deno.cwd();
  const transcriptPath = input.transcript_path || "";
  const project = cwd.split("/").pop() || "unknown";

  const ref = await getRef(cwd);
  const lastTool = await getLastTool(transcriptPath);

  const parts: string[] = [project];
  if (ref) parts[0] = `${project} (${ref})`;
  if (lastTool) parts.push(lastTool);

  await sendNotify("Gemini CLI Stop", "Done", parts.join(" | "));

  console.log("{}");
}

main().catch((err) => {
  console.error(err);
  console.log("{}");
  Deno.exit(0);
});
