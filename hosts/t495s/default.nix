{ ... }:

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

  networking.hostName = "t495s";
}
