{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.tmux = {
    enable = true;

    # Plugins managed by home-manager (replaces TPM)
    plugins = with pkgs.tmuxPlugins; [
      battery
      online-status
      cpu
      prefix-highlight
    ];

    # Include custom config via extraConfig
    extraConfig = builtins.readFile ./files/tmux.conf;
  };

  # appearance.conf is sourced from tmux.conf
  xdg.configFile = {
    "tmux/appearance.conf" = {
      source = ./files/appearance.conf;
    };
  };
}
