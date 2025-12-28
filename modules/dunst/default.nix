{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."dunst" = {
    source = ./files;
    recursive = true;
  };
}
