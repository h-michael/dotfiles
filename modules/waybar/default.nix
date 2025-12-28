{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."waybar" = {
    source = ./files;
    recursive = true;
  };
}
