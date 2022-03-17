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
      systemd-boot.enable = true;
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

  programs.steam.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  system.userActivationScripts.linktosharedfolders.text = ''
  if [[ ! -h "$HOME/git" ]]; then
    ln -s "/media/home/git" "$HOME/git"
  fi

  if [[ ! -h "$HOME/Documents" ]]; then
    rm -R "$HOME/Documents"
    ln -s "/media/home/Documents" "$HOME/Documents"
  fi

  if [[ ! -h "$HOME/Downloads" ]]; then
    rm -R "$HOME/Downloads"
    ln -s "/media/home/Downloads" "$HOME/Downloads"
  fi
  '';
}
