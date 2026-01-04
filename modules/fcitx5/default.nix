{ pkgs, ... }:

{
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
