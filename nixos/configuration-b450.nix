{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-b450.nix
    ./base.nix
  ];

  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      grub = {
         enable = pkgs.lib.mkForce true;
         efiSupport = true;
         extraEntries = ''
          menuentry "Manjaro" {
            search --set=manjaro --fs-uuid fc1993a4-3fda-405f-948d-473071664b3c
            configfile "($manjaro)/boot/grub/grub.cfg"
          }
        '';
         device = "nodev";
      };
      systemd-boot.enable = false;
    };
  };

  networking = {
    hostName = pkgs.lib.mkForce "nixos-b450";
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.enp34s0.useDHCP = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
