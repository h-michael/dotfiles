{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Note: fcitx5 service is managed by i18n.inputMethod module (modules/fcitx5)
  # Note: dunst is managed by services.dunst (modules/dunst)
  systemd.user.services = {
    waybar = {
      Unit = {
        Description = "Waybar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "simple";
        KillMode = "process";
        ExecStart = "%h/.config/waybar/script/waybar-launcher.sh";
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    waybar-restart = {
      Unit = {
        Description = "Restart Waybar on config change";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user restart waybar.service";
      };
    };

    # Shared services (compositor-agnostic)

    nm-applet = {
      Unit = {
        Description = "Network Manager applet";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    blueman-applet = {
      Unit = {
        Description = "Blueman Bluetooth applet";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.blueman}/bin/blueman-applet";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    udiskie = {
      Unit = {
        Description = "Udiskie automounter";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.udiskie}/bin/udiskie --tray";
        Restart = "on-failure";
        # udisks2 D-Bus service may not be ready immediately
        RestartSec = 3;
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    cliphist-text = {
      Unit = {
        Description = "Clipboard history (text)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    cliphist-image = {
      Unit = {
        Description = "Clipboard history (image)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Hyprland-only: xremap with hyprland variant
    xremap = {
      Unit = {
        Description = "xremap (Hyprland)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
      };
      Service = {
        ExecStart = "${pkgs.xremap.passthru.hyprland}/bin/xremap --watch=config --watch=device %h/.config/xremap/config.yml";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # niri-only: xremap with wlroots variant
    xremap-niri = {
      Unit = {
        Description = "xremap (niri)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "NIRI_SOCKET";
      };
      Service = {
        ExecStart = "${pkgs.xremap.passthru.wlroots}/bin/xremap --watch=config --watch=device %h/.config/xremap/config.yml";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # niri-only: swayidle
    swayidle = {
      Unit = {
        Description = "Idle manager (niri)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "NIRI_SOCKET";
      };
      Service = {
        Type = "simple";
        ExecStart = builtins.concatStringsSep " " [
          "${pkgs.swayidle}/bin/swayidle -w"
          "timeout 300 '${pkgs.swaylock}/bin/swaylock -f'"
          "timeout 305 'niri msg action power-off-monitors'"
          "resume 'niri msg action power-on-monitors'"
          "before-sleep '${pkgs.swaylock}/bin/swaylock -f'"
        ];
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # niri-only: swaybg wallpaper
    swaybg = {
      Unit = {
        Description = "Wallpaper (niri)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "NIRI_SOCKET";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -c '#1a1b26'";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  systemd.user.paths = {
    waybar-restart = {
      Unit = {
        Description = "Watch for Waybar config changes";
      };
      Path = {
        PathChanged = [
          "%h/.config/waybar/"
          "%h/.config/waybar/config.jsonc"
          "%h/.config/waybar/config-niri.jsonc"
          "%h/.config/waybar/style.css"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # Session targets: started by compositor's exec-once/spawn-at-startup after
  # dbus-update-activation-environment propagates env vars to systemd.
  # Starting these targets pulls in graphical-session.target (via Requires),
  # which activates all WantedBy services (waybar, xremap, etc.).
  systemd.user.targets = {
    hyprland-session = {
      Unit = {
        Description = "Hyprland Session";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
      };
    };

    niri-session = {
      Unit = {
        Description = "niri Session";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
      };
    };
  };
}
