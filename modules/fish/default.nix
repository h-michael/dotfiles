{
  config,
  pkgs,
  lib,
  ...
}:

let
  fishFilesPath = ./files;
in
{
  programs.fish.enable = true;

  # Disable man cache generation (slow rebuild caused by fish enabling this)
  # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365
  programs.man.generateCaches = false;

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

    # Note: On macOS with nix-darwin, PATH and environment are handled by
    # /etc/fish/nixos-env-preinit.fish which sources the set-environment script.
    # No manual 000_nix.fish workaround needed.
  };
}
