{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."fastfetch/config.jsonc" = {
    source = ./files/config.jsonc;
  };
}
