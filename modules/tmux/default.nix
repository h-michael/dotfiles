{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Plugin paths for manual loading
  pluginDir = "${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery";
  onlineStatusDir = "${pkgs.tmuxPlugins.online-status}/share/tmux-plugins/online-status";
  cpuDir = "${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu";
  prefixHighlightDir = "${pkgs.tmuxPlugins.prefix-highlight}/share/tmux-plugins/prefix-highlight";

  # Build complete tmux.conf with correct ordering
  tmuxConf = ''
    # Basic settings managed by home-manager
    set -g default-terminal "screen"
    set -g base-index 1
    setw -g pane-base-index 1
    set -g status-keys vi
    set -g mode-keys vi
    set -g mouse on
    set -g focus-events off
    setw -g aggressive-resize off
    setw -g clock-mode-style 24
    set -s escape-time 500
    set -g history-limit 2000

    # Load appearance config BEFORE plugins
    ${builtins.readFile ./files/appearance.conf}

    # Load plugins AFTER status-right is set
    run-shell ${pluginDir}/battery.tmux
    run-shell ${onlineStatusDir}/online_status.tmux
    run-shell ${cpuDir}/cpu.tmux
    run-shell ${prefixHighlightDir}/prefix_highlight.tmux

    # Load custom config
    ${builtins.readFile ./files/tmux.conf}
  '';
in
{
  # Manage tmux.conf directly via xdg.configFile instead of programs.tmux
  # This gives us full control over the configuration order
  xdg.configFile."tmux/tmux.conf".text = tmuxConf;

  # Install tmux packages (normal + ASan-enabled for debugging)
  home.packages = [
    pkgs.tmux
    pkgs.tmux-asan
  ];
}
