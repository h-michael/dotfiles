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
  resurrectDir = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect";
  continuumDir = "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum";

  # Build complete tmux.conf with correct ordering
  tmuxConf = ''
    # Basic settings, keybindings, and options
    ${builtins.readFile ./files/tmux.conf}

    # Appearance (status-right must be set before plugins that reference it)
    ${builtins.readFile ./files/appearance.conf}

    # Plugins
    run-shell ${pluginDir}/battery.tmux
    run-shell ${onlineStatusDir}/online_status.tmux
    run-shell ${cpuDir}/cpu.tmux
    run-shell ${prefixHighlightDir}/prefix_highlight.tmux

    # Session persistence (resurrect must be loaded before continuum)
    set -g @resurrect-strategy-nvim 'session'
    set -g @resurrect-capture-pane-contents 'on'
    set -g @resurrect-save 'S'
    set -g @resurrect-restore 'R'
    run-shell ${resurrectDir}/resurrect.tmux
    set -g @continuum-restore 'on'
    set -g @continuum-save-interval '15'
    run-shell ${continuumDir}/continuum.tmux

    # Resurrect keybinding descriptions (after plugin loads)
    bind-key -N "Save session (resurrect)" -T prefix S run-shell ${resurrectDir}/scripts/save.sh
    bind-key -N "Restore session (resurrect)" -T prefix R run-shell ${resurrectDir}/scripts/restore.sh
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
