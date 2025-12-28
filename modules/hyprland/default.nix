{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."hypr" = {
    source = ./files;
    recursive = true;
  };
}
