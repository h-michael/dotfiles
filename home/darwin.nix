{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./common.nix

    # macOS-specific modules
    ../modules/karabiner
    ../modules/scripts-darwin
  ];

  # macOS-specific packages (migrated from Homebrew)
  home.packages = with pkgs; [
    # Shell & Core utilities
    bash
    zsh
    coreutils
    findutils
    diffutils
    gnused
    gnumake
    tree
    ncdu
    unzip
    wget
    curl

    # Development tools
    cmake
    ninja
    go
    perl
    shfmt
    tokei
    hub
    tig
    watchexec
    sccache
    go-task # Task runner (Make alternative)
    plantuml # UML diagram generator
    gperf # Perfect hash function generator
    expect # Automating interactive applications
    autoconf
    automake
    xh # HTTP client (Rust implementation of httpie)
    lazygit # Git TUI
    hyperfine # Command-line benchmarking tool
    just # Task runner (Make alternative)
    tealdeer # tldr client (simplified man pages)
    delve # Go debugger
    miller # CSV/JSON/TSV data processing
    qsv # High-performance CSV toolkit

    # Languages
    luajit # (luajit only - lua conflicts with luajit's /bin/lua)
    luarocks
    openjdk

    # Libraries
    boost
    protobuf
    readline

    # Container & Kubernetes
    kubernetes-helm
    k9s
    kind
    kubeconform

    # Database tools
    postgresql_16
    redis
    tbls # Database schema documentation
    pgcli # PostgreSQL REPL with autocomplete
    mycli # MySQL REPL with autocomplete
    usql # Universal SQL client
    sqlite-utils # SQLite CLI utilities

    # Network & Security
    nmap
    grpcurl
    iperf3
    websocat
    pinentry_mac
    mqttx-cli # MQTT client CLI
    netcat # Network utility
    gnupg

    # Documentation & Text
    pandoc
    glow

    # System utilities
    fastfetch
    btop # Resource monitor
    terminal-notifier
    rclone # Cloud storage sync
    restic # Backup tool
  ];
}
