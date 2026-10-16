{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Pin the interpreter to the Nix store so the scripts don't depend on PATH.
  bunScript =
    file:
    builtins.replaceStrings [ "#!/usr/bin/env bun" ] [ "#!${pkgs.bun}/bin/bun" ] (
      builtins.readFile file
    );
  yankScript = pkgs.writeTextFile {
    name = "yank";
    text = builtins.readFile ./files/yank;
    executable = true;
    destination = "/bin/yank";
  };
  gitSyncScript = pkgs.writeTextFile {
    name = "git-sync";
    text = builtins.readFile ./files/git-sync;
    executable = true;
    destination = "/bin/git-sync";
  };
  ccStatuslineScript = pkgs.writeTextFile {
    name = "cc-statusline";
    text = bunScript ./files/cc-statusline.ts;
    executable = true;
    destination = "/bin/cc-statusline";
  };
  ccSubagentStatuslineScript = pkgs.writeTextFile {
    name = "cc-subagent-statusline";
    text = bunScript ./files/cc-subagent-statusline.ts;
    executable = true;
    destination = "/bin/cc-subagent-statusline";
  };
  ccHookStopScript = pkgs.writeTextFile {
    name = "cc-hook-stop";
    text = bunScript ./files/cc-hook-stop.ts;
    executable = true;
    destination = "/bin/cc-hook-stop";
  };
  ccHookNotificationScript = pkgs.writeTextFile {
    name = "cc-hook-notification";
    text = bunScript ./files/cc-hook-notification.ts;
    executable = true;
    destination = "/bin/cc-hook-notification";
  };
  geminiHookNotificationScript = pkgs.writeTextFile {
    name = "gemini-hook-notification";
    text = bunScript ./files/gemini-hook-notification.ts;
    executable = true;
    destination = "/bin/gemini-hook-notification";
  };
  geminiHookStopScript = pkgs.writeTextFile {
    name = "gemini-hook-stop";
    text = bunScript ./files/gemini-hook-stop.ts;
    executable = true;
    destination = "/bin/gemini-hook-stop";
  };
in
{
  home.packages = [
    yankScript
    gitSyncScript
    ccStatuslineScript
    ccSubagentStatuslineScript
    ccHookStopScript
    ccHookNotificationScript
    geminiHookNotificationScript
    geminiHookStopScript
  ];
}
