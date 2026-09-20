{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Plugins are loaded directly from their Nix store paths below, rather than
  # through TPM. Keep the packages in home.packages as well so they are part of
  # the user's managed installation and remain available independently of the
  # generated tmux.conf.
  prefixHighlight = pkgs.tmuxPlugins.prefix-highlight;
  resurrect = pkgs.tmuxPlugins.resurrect;
  prefixHighlightDir = "${prefixHighlight}/share/tmux-plugins/prefix-highlight";
  resurrectDir = "${resurrect}/share/tmux-plugins/resurrect";
  copyPaneDir = inputs.tmux-copy-pane;

  # Periodic resurrect save driven by an OS timer instead of tmux-continuum.
  #
  # continuum has no timer of its own: it appends #(continuum_save.sh) to
  # status-right and checks "has 15 min passed?" on every status tick, in
  # every session, spawning ~10 processes per check (tmux show-option x3,
  # date, a version-check script). Measured with 43 sessions that alone
  # cost ~2.7 points of Falcon CPU at status-interval 15 and ~21 points
  # at status-interval 1. A launchd/systemd timer runs save.sh once per
  # interval regardless of session count or status-interval.
  resurrectSaveIntervalSec = 15 * 60;
  resurrectSave = pkgs.writeShellScript "tmux-resurrect-save" ''
    # launchd/systemd start with a near-empty PATH; save.sh needs these.
    # /usr/bin:/bin is for ps on macOS.
    export PATH=${
      lib.makeBinPath (
        [
          pkgs.bash
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.gnused
          pkgs.gawk
          pkgs.findutils
          pkgs.tmux
        ]
        ++ lib.optional pkgs.stdenv.isLinux pkgs.procps
      )
    }:/usr/bin:/bin
    # No server running means nothing to save; exit cleanly so the timer
    # does not log a failure every interval.
    tmux has-session 2>/dev/null || exit 0
    exec tmux run-shell "${resurrectDir}/scripts/save.sh quiet"
  '';

  # Lightweight replacements for tmux-online-status/cpu/battery.
  #
  # Those plugins re-ran ping/iostat/pmset from scratch on every
  # status-interval tick, in every tmux session -- including detached
  # ones, which tmux keeps refreshing in the background. With dozens of
  # sessions open that adds up to a steady stream of forked processes
  # and (for online-status) outbound network probes, which was driving
  # up CrowdStrike Falcon's CPU usage. cachedStatus wraps each check so
  # the real command runs at most once per TTL, shared across all
  # sessions, instead of once per session per tick.
  #
  # statusInterval is the single source of truth for how often tmux
  # re-runs status-right at all. Each session fires on its own
  # schedule, so with N open sessions the combined call rate is roughly
  # N times higher than a single session's -- that's the real cost this
  # cache is fixing, not per-item freshness. Setting every TTL equal to
  # statusInterval already collapses that N-times-per-interval fan-out
  # down to one real execution per interval, which is all the value
  # this cache needs to provide; there's no benefit to tuning TTLs any
  # differently per item.
  statusInterval = 15;
  ttl = toString statusInterval;

  cachedStatus = pkgs.writeShellScript "tmux-cached-status" (
    builtins.readFile ./files/scripts/cached_status.sh
  );
  # One script emits the whole online/cpu/battery segment: tmux spawns a
  # job per #(), so a single #() is three times fewer processes per tick.
  statusRightScript = pkgs.writeShellScript "tmux-status-right" (
    builtins.readFile ./files/scripts/status_right.sh
  );

  statusRight = ''
    set -g status-interval ${toString statusInterval}
    set -g status-right "#[fg=#{@hl_bg},bg=default,nobold,nounderscore,noitalics]#[fg=#{@hl_fg},bg=#{@hl_bg}]  #(${cachedStatus} status_right ${ttl} ${statusRightScript})  %b/%d %H:%M:%S"
  '';

  # Build complete tmux.conf with correct ordering
  tmuxConf = ''
    # Basic settings, keybindings, and options
    ${builtins.readFile ./files/tmux.conf}

    # Appearance
    ${builtins.readFile ./files/appearance.conf}

    ${statusRight}

    # Plugins
    run-shell ${prefixHighlightDir}/prefix_highlight.tmux

    # Session persistence. Periodic saves come from an OS timer (see
    # resurrectSave above), not from a tmux plugin.
    set -g @resurrect-strategy-nvim 'session'
    set -g @resurrect-capture-pane-contents 'on'
    set -g @resurrect-save 'S'
    set -g @resurrect-restore 'R'
    run-shell ${resurrectDir}/resurrect.tmux

    # Restore the last save once per server start. The marker is a
    # server-scoped user option, so re-sourcing the config (prefix+r)
    # sees it already set and does not restore again. -b keeps startup
    # from blocking on the restore.
    if-shell -F '#{==:#{@resurrect-restored},}' \
      'set -s @resurrect-restored 1 ; run-shell -b "${resurrectDir}/scripts/restore.sh"'

    # Resurrect keybinding descriptions (after plugin loads)
    bind-key -N "Save session (resurrect)" -T prefix S run-shell ${resurrectDir}/scripts/save.sh
    bind-key -N "Restore session (resurrect)" -T prefix R run-shell ${resurrectDir}/scripts/restore.sh

    # Copy pane output to clipboard
    run-shell ${copyPaneDir}/tmux-copy-pane.tmux
  '';
in
{
  # Manage tmux.conf directly via xdg.configFile instead of programs.tmux
  # This gives us full control over the configuration order
  xdg.configFile."tmux/tmux.conf".text = tmuxConf;

  home.packages = [
    pkgs.tmux
    prefixHighlight
    resurrect
  ];

  # Both option trees exist on every platform in Home Manager (launchd is
  # enabled by default on Darwin, systemd.user on Linux), so gate the values
  # with mkIf. Gating the attribute names themselves (optionalAttrs / //)
  # makes the module's shape depend on pkgs and triggers infinite recursion.
  launchd.agents.tmux-resurrect-save = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${resurrectSave}" ];
      StartInterval = resurrectSaveIntervalSec;
      ProcessType = "Background";
    };
  };

  systemd.user.services.tmux-resurrect-save = lib.mkIf pkgs.stdenv.isLinux {
    Unit.Description = "Save tmux sessions with tmux-resurrect";
    Service = {
      Type = "oneshot";
      ExecStart = "${resurrectSave}";
    };
  };
  systemd.user.timers.tmux-resurrect-save = lib.mkIf pkgs.stdenv.isLinux {
    Unit.Description = "Periodic tmux-resurrect save";
    Timer = {
      OnBootSec = "${toString resurrectSaveIntervalSec}s";
      OnUnitActiveSec = "${toString resurrectSaveIntervalSec}s";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
