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

  # Homebrew supply-chain hardening. Attestation verification needs the `gh`
  # CLI (already in home/common.nix).
  home.sessionVariables = {
    HOMEBREW_NO_AUTO_UPDATE = "1";
    HOMEBREW_NO_INSECURE_REDIRECT = "1";
    HOMEBREW_VERIFY_ATTESTATIONS = "1";
    HOMEBREW_NO_ANALYTICS = "1";
  };

  # Expire Home Manager and user profile generations older than 14 days,
  # then collect the store. Run as the user, nix-collect-garbage skips the
  # system profile; the daemon in hosts/darwin handles that one.
  # nix.gc is not used: its launchd agent passes `options` as one argument,
  # and nix-collect-garbage rejects "--delete-older-than 14d" in that form.
  launchd.agents.nix-gc = {
    enable = true;
    config = {
      ProgramArguments = [
        "/nix/var/nix/profiles/default/bin/nix-collect-garbage"
        "--delete-older-than"
        "14d"
      ];
      StartCalendarInterval = [
        {
          Weekday = 7;
          Hour = 3;
          Minute = 45;
        }
      ];
      ProcessType = "Background";
    };
  };

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
    pkgs.unstable.tbls # Database schema documentation (unstable for latest)

    # Network & Security
    pinentry_mac
    mqttx-cli # MQTT client CLI
    gnupg

    # Documentation & Text
    pandoc
    glow
    poppler-utils # PDF utilities (pdftoppm, pdftotext, etc.)

    # System utilities
    # nixos-26.05 ships 2.0.0, an x86_64-only prebuilt binary that runs
    # under Rosetta; 3.x is a universal build.
    pkgs.unstable.terminal-notifier

    # Monitoring
    python3Packages.datadog # Datadog CLI (dog, dogwrap)
  ];
}
