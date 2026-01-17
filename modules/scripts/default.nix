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
in
{
  home.packages = [ yankScript ];
  home.file.".claude/statusline.ts".source = ./files/cc-statusline.ts;
}
