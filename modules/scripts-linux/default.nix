{
  config,
  pkgs,
  lib,
  ...
}:

let
  claudeCodeNotifyScript = pkgs.writeTextFile {
    name = "claude_code_notify.sh";
    text = builtins.readFile ./files/claude_code_notify.sh;
    executable = true;
    destination = "/bin/claude_code_notify.sh";
  };

  claudeCodeNotifyTs = pkgs.writeTextFile {
    name = "claude_code_notify.ts";
    text = builtins.readFile ./files/claude_code_notify.ts;
    executable = true;
    destination = "/bin/claude_code_notify.ts";
  };
in
{
  home.packages = [
    claudeCodeNotifyScript
    claudeCodeNotifyTs
  ];
}
