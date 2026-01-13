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
    # Terminals
    ghostty
    kitty

    # Development tools
    xh # HTTP client (Rust implementation of httpie)
    lazygit # Git TUI
    btop # Resource monitor
    hyperfine # Command-line benchmarking tool
    just # Task runner (Make alternative)
    tealdeer # tldr client (simplified man pages)
    gdb # GNU debugger
    delve # Go debugger
    miller # CSV/JSON/TSV data processing
    qsv # High-performance CSV toolkit
    watchman # File watching service

    # Container tools
    lazydocker # Docker TUI
    dive # Docker image layer analyzer
    trivy # Container security scanner
    ctop # Container metrics (top-like interface)

    # Network diagnostics
    iputils # ping
    traceroute

    # Database tools
    usql # Universal SQL client
    sqlite-utils # SQLite CLI utilities

    # Performance analysis
    valgrind # Memory debugger and profiler
    strace # System call tracer

    # Backup & sync
    rclone # Cloud storage sync
    restic # Backup tool

    # Development GUI
    bruno # API client (Postman alternative, Git-friendly)
    dbeaver-bin # Database management tool
    wireshark # Network protocol analyzer

    # Browsers & media
    firefox
    google-chrome
    vlc
    obs-studio

    # File management
    kdePackages.dolphin # KDE file manager

    # AI & productivity
    lmstudio # Local LLM GUI
    opencode # AI coding agent for terminal
    enpass # Password manager

    # Communication
    discord
    (vesktop.override {
      withMiddleClickScroll = true; # Enable middle-click autoscroll
    })
    slack
    kdePackages.kdeconnect-kde # Android integration (file sharing, notifications, clipboard sync)

    # Audio
    pavucontrol # PipeWire/PulseAudio GUI
    sound-theme-freedesktop # System sound files

    # Music production
    asunder # GTK CD ripper (fast, CDDB support)
    whipper # Accurate CD ripper (AccurateRip verification, slow)
    cdparanoia # CD ripping engine
    lame # MP3 encoder
    flac # FLAC encoder
    picard # MusicBrainz tagger (auto-fetch metadata)
    kid3 # Tag editor with lyrics support

    # Unity development
    unityhub # Unity installer and project manager
    dotnet-sdk_8 # .NET SDK for C# development
    mono # Required by some Unity tools

    # Hyprland/Wayland
    rofi
    waybar
    wl-clipboard # Clipboard (wl-copy, wl-paste)
    grim # Screenshot
    slurp # Region selection for screenshots
    swappy # Screenshot annotation/editor
    wf-recorder # Screen recording
    cliphist # Clipboard history manager
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
