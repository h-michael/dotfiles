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
in
{
  home.packages = [
    yankScript
    ccStatuslineScript
  ];
}
