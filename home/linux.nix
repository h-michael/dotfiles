{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./common.nix

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
    ../modules/vscode
    ../modules/swappy
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
    enpass # Password manager

    # Unity development
    unityhub # Unity installer and project manager
    dotnet-sdk_8 # .NET SDK for C# development
    mono # Required by some Unity tools

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
    wtype # Wayland keyboard input tool
  ];

  # Cursor theme
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # GTK/Qt theme settings are in modules/theme
  # fcitx5 im-module settings are in modules/fcitx5

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
