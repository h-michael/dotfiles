{
  pkgs,
  username,
  unstablePkgs,
  ...
}:

{
  imports = [
    ../linux/common.nix
    ./hardware-configuration.nix
    ./monitoring.nix
    ./llm.nix
  ];

  # Use latest kernel for Strix Halo (gfx1151) VRAM fix
  # Reference: https://github.com/ROCm/ROCm/issues/5444
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.timeout = null;

  # Use systemd-boot
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 15;
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

  # I2C support for DDC/CI (external display brightness control)
  boot.kernelModules = [
    "i2c-dev"
    "mt7925e"
  ];

  # Prevent btusb from auto-binding before the TP-Link adapter is removed.
  # The boot-time workaround service loads btusb explicitly after udev rules
  # have had a chance to detach the external Realtek dongle.
  boot.blacklistedKernelModules = [ "btusb" ];

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

  swapDevices = [
    { device = "/dev/disk/by-uuid/fadc1b39-e7bf-4bd9-9487-7979adb5c485"; }
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/fadc1b39-e7bf-4bd9-9487-7979adb5c485";

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

  # Networking
  networking.hostName = "ms-s1-max";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    extraCommands = ''
      # KDE Connect: Allow only from local and Tailscale networks

      # Local network (home WiFi, etc.)
      iptables -A nixos-fw -p tcp --dport 1714:1764 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --dport 1714:1764 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 1714:1764 -s 10.0.0.0/8 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --dport 1714:1764 -s 10.0.0.0/8 -j nixos-fw-accept

      # Tailscale network
      iptables -A nixos-fw -p tcp --dport 1714:1764 -s 100.64.0.0/10 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --dport 1714:1764 -s 100.64.0.0/10 -j nixos-fw-accept
    '';
  };

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
  # Disable TP-Link Bluetooth USB Adapter (use internal MT7925 instead)
  # USB ID: 2357:0604
  services.udev.extraRules = ''
    # Disable TP-Link Bluetooth USB Adapter
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2357", ATTR{idProduct}=="0604", ATTR{authorized}="0", ATTR{remove}="1"

    # WebHID needs read-write access; explicit ownership avoids relying on uaccess ACLs.
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="${username}"
    SUBSYSTEM=="usb", ATTR{idVendor}=="3434", MODE="0660", GROUP="${username}"
  '';

  # ddcutil udev rules for I2C device access
  services.udev.packages = [ pkgs.ddcutil ];

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
      RemainAfterExit = true;
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };

  # Workaround: Reload btusb at boot to work around MT7925 init race
  #
  # The MT7925 btmtk driver has a race condition where usb_autopm_put_interface()
  # is called before the WMT event response arrives, causing intermittent
  # "wmt command timed out" failures on first initialization. Reloading btusb
  # forces a clean re-initialization that bypasses the timing-sensitive path.
  #
  # Only btusb is reloaded to avoid disrupting Wi-Fi (mt7925e is a combo driver).
  # If btusb-only reload is insufficient, mt7925e reload may also be needed.
  #
  # Candidate upstream fix (under review as of 2026-03):
  #   https://lists.infradead.org/pipermail/linux-mediatek/2025-March/090780.html
  # Reference:
  #   https://github.com/moolooite/mt7925e-bt-heal
  systemd.services.mt7925e-bt-heal = {
    description = "Reload btusb to work around MT7925 Bluetooth init race";
    before = [ "bluetooth.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # modprobe -r may fail if btusb is not yet loaded; ignore that case
      ExecStart = "${pkgs.bash}/bin/bash -c 'for d in /sys/bus/usb/devices/*; do if [ -f \"$d/idVendor\" ] && [ -f \"$d/idProduct\" ] && [ \"$(cat \"$d/idVendor\")\" = \"2357\" ] && [ \"$(cat \"$d/idProduct\")\" = \"0604\" ] && [ -w \"$d/remove\" ]; then echo 1 > \"$d/remove\"; fi; done; ${pkgs.kmod}/bin/modprobe -r btusb || true; ${pkgs.coreutils}/bin/sleep 1; ${pkgs.kmod}/bin/modprobe btusb'";
      RemainAfterExit = true;
    };
  };

  # Navidrome music streaming server
  # Access: Tailscale only (http://<Tailscale-IP>:4533)
  services.navidrome = {
    enable = true;
    openFirewall = false; # Block access from LAN
    # Use unstable to avoid Go 1.24.12 build issue (see notes/navidrome-go124-build-issue.md)
    package = unstablePkgs.navidrome;
    settings = {
      Address = "0.0.0.0"; # Tailscale
      Port = 4533;
      MusicFolder = "/mnt/shared/Media/Music";
      ScanSchedule = "@every 1h";
      EnableTranscodingConfig = true;
      DefaultTheme = "Dark";
    };
  };

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

  environment.systemPackages = with pkgs; [
    amdgpu_top
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    clinfo
  ];
}
