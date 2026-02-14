{
  config,
  pkgs,
  lib,
  inputs,
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
    tig
    watchexec
    sccache
    go-task # Task runner (Make alternative)
    plantuml # UML diagram generator
    gperf # Perfect hash function generator
    expect # Automating interactive applications
    autoconf
    automake

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
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tbls # Database schema documentation (unstable for latest)

    # Network & Security
    pinentry_mac
    mqttx-cli # MQTT client CLI
    gnupg

    # Documentation & Text
    pandoc
    glow

    # System utilities
    terminal-notifier
  ];
}
