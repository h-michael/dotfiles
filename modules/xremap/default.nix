{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."xremap" = {
    source = ./files;
    recursive = true;
  };
}
