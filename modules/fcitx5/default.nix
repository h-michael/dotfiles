{ pkgs, lib, ... }:

{
  # Do not autostart fcitx5 via a systemd user service. On Plasma it must
  # be launched by KWin itself (as its virtual keyboard), or the Wayland
  # input method protocol never engages; Hyprland and Niri start it from
  # their own session config instead (verified 2026-11-28). The i18n
  # module defines the unit unconditionally and this home-manager
  # revision has no per-service enable flag, so drop its [Install]
  # WantedBy to keep the unit from being pulled in.
  systemd.user.services.fcitx5-daemon.Install.WantedBy = lib.mkForce [ ];

  # GTK im-module settings for fcitx5 (XWayland apps)
  # Wayland native apps use text-input-v3 protocol automatically
  gtk = {
    gtk3.extraConfig.gtk-im-module = "fcitx";
    gtk4.extraConfig.gtk-im-module = "fcitx";
  };

  # Use home-manager's i18n.inputMethod module for fcitx5
  # Reference: https://wiki.nixos.org/wiki/Fcitx5
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        # Qt 6 platform input context plugin. Required for KWin/Plasma 6 to
        # translate Wayland key events into fcitx5 keysyms (otherwise
        # "fcitx_key_event_handler.cc: Translate failed" and IME hotkeys
        # such as Zenkaku_Hankaku do nothing in KDE sessions).
        kdePackages.fcitx5-qt
      ];
      settings = {
        # Input method configuration
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
          GroupOrder = {
            "0" = "Default";
          };
        };
        # Global config (hotkeys, behavior)
        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = "True";
            EnumerateSkipFirst = "False";
          };
          "Hotkey/TriggerKeys" = {
            "0" = "Zenkaku_Hankaku";
          };
          "Hotkey/AltTriggerKeys" = {
            "0" = "Shift_L";
          };
          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };
          Behavior = {
            ActiveByDefault = "False";
            PreeditEnabledByDefault = "True";
            ShowInputMethodInformation = "True";
            DefaultPageSize = 5;
          };
        };
        # ClassicUI addon settings (tray icon)
        # Reference: https://github.com/NixOS/nixpkgs/issues/295398
        addons = {
          classicui.globalSection = {
            # Use text icon to show IME state clearly ("A" / "あ")
            PreferTextIcon = "True";
          };
        };
      };
    };
  };
}
