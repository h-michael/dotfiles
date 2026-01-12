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
  brightnessScript = pkgs.writeTextFile {
    name = "brightness";
    text = builtins.readFile ./files/brightness.ts;
    executable = true;
    destination = "/bin/brightness";
  };
in
{
  home.packages = [
    ccNotifyScript
    escReminderScript
    brightnessScript
  ];
}
