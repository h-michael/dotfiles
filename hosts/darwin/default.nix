{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Primary user for user-specific settings (required for nix-darwin 25.11+)
  system.primaryUser = username;

  # Disable nix-darwin's Nix management (using Determinate Systems Installer)
  nix.enable = false;

  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # Add fish to /etc/shells and set as default login shell
  environment.shells = [ pkgs.fish ];

  # All packages managed by home-manager (via useUserPackages = true)
  environment.systemPackages = [ ];

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  # Required for nix-darwin
  system.stateVersion = 6;
}
