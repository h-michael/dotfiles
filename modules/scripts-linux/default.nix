{
  config,
  pkgs,
  lib,
  ...
}:

let
  ccNotifyScript = pkgs.writeTextFile {
    name = "cc-notify";
    text = builtins.readFile ./files/cc-notify.ts;
    executable = true;
    destination = "/bin/cc-notify";
  };
  escReminderScript = pkgs.writeTextFile {
    name = "esc-reminder";
    text = builtins.readFile ./files/esc-reminder.ts;
    executable = true;
    destination = "/bin/esc-reminder";
  };
in
{
  home.packages = [
    ccNotifyScript
    escReminderScript
  ];
}
