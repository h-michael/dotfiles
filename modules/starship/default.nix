{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.starship.enable = true;

  xdg.configFile."starship.toml" = {
    source = ./files/starship.toml;
  };
}
