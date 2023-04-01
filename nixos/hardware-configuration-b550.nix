{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  # Fix for Fn keys on keychron
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/media/home" = {
    device = "/dev/disk/by-label/big";
    fsType = "ext4";
  };

  fileSystems."/media/containers" = {
    device = "/dev/disk/by-label/containers";
    fsType = "ext4";
  };

  fileSystems."/media/git" = {
    device = "/dev/disk/by-label/git";
    fsType = "ext4";
  };

  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
