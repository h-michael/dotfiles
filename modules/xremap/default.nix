{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."xremap/config.yml".source = ./files/config.yml;
}
