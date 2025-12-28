{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Note: fcitx5 service is managed by i18n.inputMethod module (modules/fcitx5)
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
        ExecStart = "${pkgs.waybar}/bin/waybar -c %h/.config/waybar/config.jsonc -s %h/.config/waybar/style.css";
        Restart = "on-failure";
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

    xremap = {
      Unit = {
        Description = "xremap";
      };
      Service = {
        ExecStart = "${pkgs.xremap.passthru.hyprland}/bin/xremap --watch=config %h/.config/xremap/config.yml";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Install = {
        WantedBy = [ "default.target" ];
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
          "%h/.config/waybar/style.css"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  systemd.user.targets = {
    hyprland-session = {
      Unit = {
        Description = "Hyprland Session";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
      };
    };
  };
}
