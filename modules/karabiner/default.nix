{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Karabiner-Elements configuration (macOS only)
  xdg.configFile."karabiner" = {
    source = ./files;
    recursive = true;
  };
}
