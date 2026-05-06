{ ... }:

{
  programs.plasma = {
    enable = true;

    # Register fcitx5 as KWin's Wayland input method.
    # Without this, KWin doesn't route key events through fcitx5 on Wayland
    # sessions, so IME toggle keys (e.g. Zenkaku_Hankaku) have no effect.
    configFile.kwinrc.Wayland.InputMethod = "org.fcitx.Fcitx5.desktop";

    # Disable KWin's built-in "Meta tap opens Application Launcher" behavior.
    # Without this, pressing left Cmd alone (xremap-mapped to Super_L) opens
    # Plasma's launcher, which conflicts with using Super as a plain modifier
    # (e.g. Super+Alt_R for IME activate via xremap launch).
    configFile.kwinrc.ModifierOnlyShortcuts.Meta = "";

    # plasmashell registers "Meta" alone as the launcher hotkey via
    # kglobalshortcutsrc. Override with Meta+P for parity with Hyprland's
    # `bindd = $mod, P, Application menu, exec, $menu`.
    shortcuts.plasmashell."activate application launcher" = "Meta+P";

    # Match Hyprland's workspace count (10) so Meta+1..0 covers everything.
    kwin.virtualDesktops = {
      number = 10;
      rows = 1;
    };

    # Mirror Hyprland's window/workspace keybinds in KWin. The KDE primitives
    # are virtual desktops (= workspaces) and tiling-aware focus moves.
    shortcuts.kwin = {
      # $mod, 1..0 → Switch to Desktop 1..10
      "Switch to Desktop 1" = "Meta+1";
      "Switch to Desktop 2" = "Meta+2";
      "Switch to Desktop 3" = "Meta+3";
      "Switch to Desktop 4" = "Meta+4";
      "Switch to Desktop 5" = "Meta+5";
      "Switch to Desktop 6" = "Meta+6";
      "Switch to Desktop 7" = "Meta+7";
      "Switch to Desktop 8" = "Meta+8";
      "Switch to Desktop 9" = "Meta+9";
      "Switch to Desktop 10" = "Meta+0";

      # $mod SHIFT, 1..0 → Window to Desktop 1..10
      "Window to Desktop 1" = "Meta+Shift+1";
      "Window to Desktop 2" = "Meta+Shift+2";
      "Window to Desktop 3" = "Meta+Shift+3";
      "Window to Desktop 4" = "Meta+Shift+4";
      "Window to Desktop 5" = "Meta+Shift+5";
      "Window to Desktop 6" = "Meta+Shift+6";
      "Window to Desktop 7" = "Meta+Shift+7";
      "Window to Desktop 8" = "Meta+Shift+8";
      "Window to Desktop 9" = "Meta+Shift+9";
      "Window to Desktop 10" = "Meta+Shift+0";

      # $mod, L/H → next / previous workspace
      "Switch to Next Desktop" = "Meta+L";
      "Switch to Previous Desktop" = "Meta+H";

      # $mod, arrows → focus move
      "Switch Window Left" = "Meta+Left";
      "Switch Window Right" = "Meta+Right";
      "Switch Window Up" = "Meta+Up";
      "Switch Window Down" = "Meta+Down";

      # $mod SHIFT, Return → fullscreen toggle
      "Window Fullscreen" = "Meta+Shift+Return";

      # $mod SHIFT, X → close (Hyprland's Super+Shift+X close-window-confirm)
      "Window Close" = "Meta+Shift+X";
    };

    # $mod SHIFT, L → lock screen. Default KDE Meta+L collides with our
    # next-desktop binding; move it to Shift+L to match Hyprland.
    shortcuts.ksmserver."Lock Session" = "Meta+Shift+L";
  };
}
