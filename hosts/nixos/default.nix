{
  config,
  lib,
  pkgs,
  username,
  unstablePkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./monitoring.nix
    ./llm.nix
  ];

  # Use latest kernel for Strix Halo (gfx1151) VRAM fix
  # Reference: https://github.com/ROCm/ROCm/issues/5444
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use systemd-boot
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 30;
    editor = true;
    consoleMode = "keep";
    # Dual-boot with Arch Linux
    # "zz-" prefix ensures Arch entry sorts after NixOS entries alphabetically
    extraEntries = {
      "zz-arch.conf" = ''
        title Arch Linux
        linux /vmlinuz-linux
        initrd /amd-ucode.img
        initrd /initramfs-linux.img
        options rd.luks.name=47d5b5a8-226d-4574-bcda-0fc32efbdf59=luks-linux rd.lvm.vg=vg_linux root=/dev/mapper/vg_linux-arch rootflags=subvol=@ rw rd.break
      '';
    };
  };

  boot.initrd = {
    kernelModules = [ "amdgpu" ];
    services.lvm.enable = true;
    # Enable systemd in initrd for TPM2 LUKS unlock
    systemd.enable = true;
    # LUKS encryption with TPM2 auto-unlock
    luks.devices.cryptlvm = {
      device = "/dev/disk/by-uuid/47d5b5a8-226d-4574-bcda-0fc32efbdf59";
      preLVM = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };

  # Workaround: Disable ASPM (Active State Power Management) for MediaTek MT7925
  #
  # ASPM can cause Bluetooth connection instability and firmware communication
  # timeouts on MT7925 Wi-Fi/Bluetooth combo chips.
  #
  # References:
  #   - https://bbs.archlinux.org/viewtopic.php?id=306366
  #   - https://forums.linuxmint.com/viewtopic.php?t=455342
  boot.kernelParams = [
    "mt7925e.disable_aspm=1"
    # Disable USB autosuspend to fix MT7925 Bluetooth connection issues
    # Workaround for br-connection-create-socket error until kernel 6.17+
    # Reference: https://forums.linuxmint.com/viewtopic.php?t=455342
    "usbcore.autosuspend=-1"
    # AMD P-State driver for better CPU power management
    # Reference: https://wiki.archlinux.org/title/CPU_frequency_scaling#amd_pstate
    "amd_pstate=active"
  ];

  # Apple Magic Keyboard: F1-F12 as default function keys
  # fnmode: 0 = disabled, 1 = Fn key pressed = F1-F12, 2 = Fn key pressed = media keys
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  nixpkgs.config.allowUnfree = true;

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Time zone and locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Bluetooth (with MT7925 workarounds)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
  services.blueman.enable = true;

  # Workaround: MediaTek MT7925 Bluetooth is soft-blocked on boot with kernel 6.12+
  #
  # Symptoms:
  #   - `rfkill list` shows "Soft blocked: yes" for Bluetooth
  #   - `bluetoothctl show` returns "No default controller available"
  #   - journalctl shows "Bluetooth: hci0: Execution of wmt command timed out"
  #
  # This service runs `rfkill unblock bluetooth` before bluetooth.service starts.
  #
  # References:
  #   - https://discourse.nixos.org/t/bluetooth-is-soft-blocked-on-startup-6-12/60222
  #   - https://bbs.archlinux.org/viewtopic.php?id=310216
  #   - https://github.com/ublue-os/bazzite/issues/3337
  systemd.services.bluetooth-rfkill-unblock = {
    description = "Unblock Bluetooth via rfkill";
    wantedBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };

  # Keyboard
  services.xserver.xkb.layout = "us";

  # xremap needs uinput access
  hardware.uinput.enable = true;

  # Hyprland
  programs.hyprland.enable = true;

  # ydotool for gesture key simulation
  programs.ydotool.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Steam Remote Play
    dedicatedServer.openFirewall = true; # Steam dedicated server
    # Proton for Windows games
    extraCompatPackages = with pkgs; [
      proton-ge-bin # GloriousEggroll's custom Proton (better compatibility)
    ];
  };
  programs.gamemode.enable = true; # Performance optimization for games

  # XDG Desktop Portal for screen sharing in Discord/Slack
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland # Screen sharing for Hyprland
      xdg-desktop-portal-gtk # File dialogs
    ];
  };

  # greetd login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
  };

  # Tailscale VPN
  services.tailscale.enable = true;

  # Navidrome music streaming server
  # Access: Tailscale only (http://<Tailscale-IP>:4533)
  services.navidrome = {
    enable = true;
    openFirewall = false; # Block access from LAN
    settings = {
      Address = "0.0.0.0"; # Tailscale
      Port = 4533;
      MusicFolder = "/mnt/shared/Media/Music";
      ScanSchedule = "@every 1h";
      EnableTranscodingConfig = true;
      DefaultTheme = "Dark";
    };
  };

  # Security / PAM
  security.pam.services = {
    hyprlock = { };
  };

  security.rtkit.enable = true;

  # TPM2 support for LUKS automatic unlock
  #
  # Allows automatic LUKS decryption using TPM2 chip, eliminating the need
  # for password input at boot (useful when Bluetooth keyboard is unavailable).
  #
  # After `make switch`, run:
  #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-uuid/<uuid>
  #
  # References:
  #   - https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde/
  #   - https://discourse.nixos.org/t/tpm2-luks-unlock-not-working/52342
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Temp cleanup
  boot.tmp.cleanOnBoot = true;

  # AMD GPU (Strix Halo / RDNA 3.5)
  # Reference: https://wiki.nixos.org/wiki/AMD_GPU
  hardware.graphics = {
    enable = true;
    # 32-bit application support (Steam, Wine, etc.)
    enable32Bit = true;
    # OpenCL support via ROCm
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  # HIP support for AMD GPU (many applications hardcode /opt/rocm/hip path)
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Shell configuration
  programs.fish.enable = true;

  # Disable man cache generation (slow rebuild caused by fish enabling this)
  # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365
  documentation.man.generateCaches = false;

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    group = username;
    extraGroups = [
      "wheel"
      "input"
      "uinput"
      "video" # Webcam access for Discord/Slack video calls
      "audio" # Audio device access
      "optical" # CD/DVD drive access
      "cdrom" # CD/DVD drive access
      "ydotool" # ydotool socket access for gesture key simulation
    ];
    shell = pkgs.fish;
  };

  users.groups.${username} = { };

  # Allow passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    # Core (used with sudo)
    curl
    wget
    git
    openssh
    htop
    tmux
    vim
    neovim

    # Utils
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
    pciutils
    tpm2-tools
    nixfmt-tree # Recursive nix formatter

    # Hyprland system dependencies (need hardware access or system integration)
    dunst
    brightnessctl
    playerctl
    networkmanagerapplet # nm-applet
    blueman
    udiskie
    hyprlock
    hypridle

    # GPU stuff
    vulkan-tools
    mesa

    # AMD GPU monitoring
    amdgpu_top # TUI for AMDGPU usage (like nvidia-smi)
    radeontop # Classic AMD GPU monitor
    rocmPackages.rocm-smi # ROCm System Management Interface
    rocmPackages.rocminfo # GFX version info (rocminfo | grep gfx)
    clinfo # OpenCL info

    # Webcam
    v4l-utils # Webcam tools (v4l2-ctl)
  ];

  # Fonts (must use fonts.packages, not environment.systemPackages)
  fonts.packages = with pkgs; [
    cica-font
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    liberation_ttf
    nerd-fonts.symbols-only # For waybar icons
    font-awesome_6 # For waybar icons
  ];

  system.stateVersion = "24.11";
}
