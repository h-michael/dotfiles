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

      # Platform-specific settings
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        font-size = 14
        fullscreen = true
      ''}
      ${lib.optionalString pkgs.stdenv.isLinux ''
        font-size = 16
        fullscreen = false
        # Font rendering (Linux/FreeType only)
        freetype-load-flags = hinting,autohint
      ''}
    '';
  };
}
