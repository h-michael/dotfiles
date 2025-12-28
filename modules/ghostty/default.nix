{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."ghostty/config" = {
    source = ./files/config;
  };
}
