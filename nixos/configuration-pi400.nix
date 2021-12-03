{ config, pkgs, lib, ... }:

{
  imports = [
    <nixos-hardware/raspberry-pi/4>
    ./base.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    kernelPackages = pkgs.linuxPackages_rpi4;
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
    loader = {
      raspberryPi = {
        enable = true;
        version = 4;
      };
      generic-extlinux-compatible.enable = true;
      raspberryPi.firmwareConfig = ''
        dtparam=audio=on
        dtparam=sd_poll_once=on
      '';
    };
    tmpOnTmpfs = true;
  };

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  hardware = {
    # Required for the Wireless firmware
    enableRedistributableFirmware = true;

    raspberry-pi."4".fkms-3d.enable = true;
  };

  networking.hostName = pkgs.lib.mkForce "nixos-rpi400";

  powerManagement.cpuFreqGovernor = "ondemand";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05";
}
