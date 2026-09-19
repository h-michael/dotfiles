{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];

  boot.initrd.services.lvm.enable = true;
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/6ca8d89a-ebb4-43ef-868a-d9ecc89b9776";
    preLVM = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/archlinux-root";
    fsType = "btrfs";
    options = [
      "ssd"
      "space_cache=v2"
      "subvol=/"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/archlinux-home";
    fsType = "btrfs";
    options = [
      "ssd"
      "space_cache=v2"
      "subvol=/"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6179-5CF7";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/5a85a964-b63b-4e89-a100-8244c2a0fc55"; }
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/5a85a964-b63b-4e89-a100-8244c2a0fc55";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
