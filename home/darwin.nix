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
    watchexec

    # Lua (luajit only - lua conflicts with luajit's /bin/lua)
    luajit
    luarocks

    # Java
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

    # Network & Security
    nmap
    grpcurl
    iperf3
    websocat
    pinentry_mac
    mqttx-cli # MQTT client CLI
    netcat # Network utility
    gnupg

    # Database
    postgresql_16
    redis
    tbls # Database schema documentation
    # mysql  # Uncomment if needed

    # Documentation & Text
    pandoc
    glow

    # System info
    fastfetch

    # Notifications
    terminal-notifier
  ];
}
