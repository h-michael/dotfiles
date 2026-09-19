{ username, ... }:

{
  imports = [
    ../linux/common.nix
    ./hardware-configuration.nix
  ];

  boot.loader.timeout = 3;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = true;
    consoleMode = "keep";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/18cdeee4-a471-43f1-82a8-b753a2ab8fd6";
    preLVM = true;
  };

  boot.initrd.services.lvm.enable = true;

  fileSystems."/".options = [
    "x-systemd.device-timeout=infinity"
  ];

  networking.hostName = "t495s";

  home-manager.users.${username}.xdg.configFile."hypr/hyprland.local.conf".source =
    ./hyprland.local.conf;

  programs.nix-ld.enable = true;
}
