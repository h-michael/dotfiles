{
  config,
  pkgs,
  lib,
  ...
}:

let
  yankScript = pkgs.writeTextFile {
    name = "yank";
    text = builtins.readFile ./files/yank;
    executable = true;
    destination = "/bin/yank";
  };
  ccStatuslineScript = pkgs.writeTextFile {
    name = "cc-statusline";
    text = builtins.readFile ./files/cc-statusline.ts;
    executable = true;
    destination = "/bin/cc-statusline";
  };
  ccHookStopScript = pkgs.writeTextFile {
    name = "cc-hook-stop";
    text = builtins.readFile ./files/cc-hook-stop.ts;
    executable = true;
    destination = "/bin/cc-hook-stop";
  };
  ccHookNotificationScript = pkgs.writeTextFile {
    name = "cc-hook-notification";
    text = builtins.readFile ./files/cc-hook-notification.ts;
    executable = true;
    destination = "/bin/cc-hook-notification";
  };
in
{
  home.packages = [
    yankScript
    ccStatuslineScript
    ccHookStopScript
    ccHookNotificationScript
  ];
}
