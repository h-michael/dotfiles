{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."fuzzel" = {
    source = ./files;
    recursive = true;
  };
}
