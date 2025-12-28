{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.configFile."ripgreprc" = {
    source = ./files/ripgreprc;
  };
}
