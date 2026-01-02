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
in
{
  home.packages = [ ccNotifyScript ];
}
