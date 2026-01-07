{
  config,
  pkgs,
  lib,
  isNixOS ? false,
  ...
}:

let
  fishFilesPath = ./files;

  # XDG_DATA_DIRS: only needed for standalone home-manager on Arch Linux
  # nix-darwin and NixOS set this via their own environment scripts
  xdgDataDirs =
    if isNixOS || pkgs.stdenv.isDarwin then
      null # Managed by NixOS/nix-darwin
    else
      # Arch or other non-NixOS Linux (standalone home-manager)
      "$HOME/.nix-profile/share:$HOME/.local/share:/usr/local/share:/usr/share";
in
{
  programs.fish.enable = true;

  # Disable man cache generation (slow rebuild caused by fish enabling this)
  # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365
  programs.man.generateCaches = false;

  # Only set XDG_DATA_DIRS for standalone home-manager (Arch Linux)
  home.sessionVariables = lib.mkIf (xdgDataDirs != null) {
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

    # themes directory - for fish_config theme
    "fish/themes" = {
      source = "${fishFilesPath}/themes";
      recursive = true;
    };

    # Note: On macOS with nix-darwin, PATH and environment are handled by
    # /etc/fish/nixos-env-preinit.fish which sources the set-environment script.
    # No manual 000_nix.fish workaround needed.
  };
}
