{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."rofi" = {
    source = ./files;
    recursive = true;
  };
}
