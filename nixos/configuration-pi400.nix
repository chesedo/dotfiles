{ config, pkgs, lib, ... }:

{
  imports = [
    <nixos-hardware/raspberry-pi/4>
    ./base.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
  };

  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };
  boot.loader.grub.enable = pkgs.lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
    dtparam=sd_poll_once=on
  '';

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  networking.hostName = pkgs.lib.mkForce "nixos-rpi400";

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";
}
