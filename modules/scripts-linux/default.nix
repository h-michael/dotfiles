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
  nixSearchScript = pkgs.writeTextFile {
    name = "nix-search";
    text = builtins.readFile ./files/nix-search.ts;
    executable = true;
    destination = "/bin/nix-search";
  };
in
{
  home.packages = [
    ccNotifyScript
    escReminderScript
    brightnessScript
    nixSearchScript
  ];
}
