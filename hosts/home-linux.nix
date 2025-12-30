{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./home.nix

    # Linux-specific modules
    ../modules/hyprland
    ../modules/waybar
    ../modules/rofi
    ../modules/dunst
    ../modules/theme
    ../modules/xremap
    ../modules/systemd
    ../modules/fcitx5
    ../modules/fontconfig
    ../modules/scripts-linux
  ];

  # Linux-specific packages
  home.packages = with pkgs; [
    # GUI applications
    firefox
    google-chrome
    vlc
    obs-studio
    kdePackages.dolphin # KDE file manager
    lmstudio # Local LLM GUI
    opencode # AI coding agent for terminal

    # Communication (with audio/video support)
    discord
    vesktop # Discord client with better Wayland screen sharing
    slack

    # Audio control
    pavucontrol # PipeWire/PulseAudio GUI

    # CD ripping
    asunder # GTK CD ripper (fast, CDDB support)
    whipper # Accurate CD ripper (AccurateRip verification, slow)
    cdparanoia # CD ripping engine
    lame # MP3 encoder
    flac # FLAC encoder

    # Music tagging
    picard # MusicBrainz tagger (auto-fetch metadata)
    kid3 # Tag editor with lyrics support

    # Terminals
    ghostty
    kitty

    # Hyprland/Wayland tools
    rofi
    waybar

    # Wayland essentials
    wl-clipboard # Clipboard (wl-copy, wl-paste)
    grim # Screenshot
    slurp # Region selection for screenshots
    swappy # Screenshot annotation/editor
    wf-recorder # Screen recording
    cliphist # Clipboard history manager

    # Wayland utilities
    wev # Event viewer (debug)
    wlr-randr # Display configuration (like xrandr)
    swww # Wallpaper daemon (animated support)
    imv # Image viewer for Wayland
    wdisplays # GUI display configuration
    libnotify # notify-send for notifications
  ];

  # Cursor theme
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # GTK settings for fcitx5 (XWayland apps)
  # Wayland native apps use text-input-v3 protocol automatically
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-im-module = "fcitx";
    };
    gtk4.extraConfig = {
      gtk-im-module = "fcitx";
    };
  };

  # Linux-specific XDG settings
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
    };
  };
}
