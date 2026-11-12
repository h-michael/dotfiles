{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.starship = {
    enable = true;
    # conf.d/99_hook.fish runs `starship init fish` itself, together with
    # the transient prompt setup; HM's copy would init starship twice.
    enableFishIntegration = false;
  };

  xdg.configFile."starship.toml" = {
    source = ./files/starship.toml;
  };
}
