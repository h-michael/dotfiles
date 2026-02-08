{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."swaylock" = {
    source = ./files;
    recursive = true;
  };
}
