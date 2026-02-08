{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."niri" = {
    source = ./files;
    recursive = true;
  };
}
