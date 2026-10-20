{
  pkgs,
  username,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  services.udisks2.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    PowerKeyLongPress = "poweroff";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

  services.xserver.xkb.layout = "us";

  hardware.uinput.enable = true;
  programs.nix-ld.enable = true;

  programs.hyprland.enable = true;
  programs.niri.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.ydotool.enable = true;

  services.xremap = {
    enable = true;
    serviceMode = "user";
    userName = username;
    yamlConfig = builtins.readFile ../../modules/xremap/files/config.yml;
  };

  systemd.user.services.xremap.path = [
    "/run/current-system/sw"
    "/etc/profiles/per-user/${username}"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  programs.gamemode.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
    extraSetFlags = [ "--ssh" ];
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        experimental = true;
        features.buildkit = true;
      };
    };
  };

  security.pam.services = {
    hyprlock = { };
    swaylock = { };
  };

  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  boot.tmp.cleanOnBoot = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.fish.enable = true;
  documentation.man.cache.enable = false;

  users.users.${username} = {
    isNormalUser = true;
    group = username;
    extraGroups = [
      "wheel"
      "input"
      "uinput"
      "video"
      "audio"
      "optical"
      "cdrom"
      "ydotool"
      "i2c"
    ];
    shell = pkgs.fish;
  };

  users.groups.${username} = { };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    nvme-cli
    smartmontools
    pciutils
    sysstat
    ddrescue
    curl
    wget
    git
    openssh
    htop
    tmux
    vim
    neovim
    unzip
    zip
    tree
    ripgrep
    fd
    fzf
    bat
    eza
    delta
    usbutils
    tpm2-tools
    nixfmt-tree
    dunst
    brightnessctl
    playerctl
    networkmanagerapplet
    blueman
    udiskie
    hyprlock
    hypridle
    swaylock
    swayidle
    fuzzel
    swaybg
    xwayland-satellite
    vulkan-tools
    mesa
    radeontop
    ddcutil
    v4l-utils
  ];

  fonts.packages = with pkgs; [
    cica-font
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    liberation_ttf
    nerd-fonts.symbols-only
    font-awesome_6
    plemoljp-nf
  ];

  system.stateVersion = "24.11";
}
