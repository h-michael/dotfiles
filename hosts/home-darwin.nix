{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./home.nix

    # macOS-specific modules
    ../modules/karabiner
  ];

  # macOS-specific packages
  home.packages = with pkgs; [
    # Add macOS-specific packages here
  ];
}
