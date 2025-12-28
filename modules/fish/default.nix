{
  config,
  pkgs,
  lib,
  isNixOS ? false,
  ...
}:

let
  fishFilesPath = ./files;

  # XDG_DATA_DIRS: different paths for each platform
  xdgDataDirs =
    if pkgs.stdenv.isDarwin then
      "$HOME/.nix-profile/share:/usr/local/share:/usr/share"
    else if isNixOS then
      "/run/current-system/sw/share:$HOME/.local/share:$HOME/.nix-profile/share:/usr/local/share:/usr/share"
    else
      # Arch or other non-NixOS Linux
      "$HOME/.nix-profile/share:$HOME/.local/share:/usr/local/share:/usr/share";
in
{
  programs.fish.enable = true;

  home.sessionVariables = {
    XDG_DATA_DIRS = xdgDataDirs;
  };

  # Use xdg.configFile to manage fish configuration files
  xdg.configFile = {
    # conf.d directory - fish sources these automatically
    "fish/conf.d" = {
      source = "${fishFilesPath}/conf.d";
      recursive = true;
    };

    # functions directory
    "fish/functions" = {
      source = "${fishFilesPath}/functions";
      recursive = true;
    };
  };
}
