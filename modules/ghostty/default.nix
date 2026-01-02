{
  config,
  pkgs,
  lib,
  ...
}:

let
  baseConfig = builtins.readFile ./files/config;
  # Use nix store path for fish - works on all platforms
  fishPath = "${pkgs.fish}/bin/fish";
in
{
  xdg.configFile."ghostty/config" = {
    text = ''
      ${baseConfig}
      # Fish shell (path resolved by Nix, works on macOS and Linux)
      command = ${fishPath} --login --interactive
    '';
  };
}
