{ config, pkgs, lib, ... }:

{
  imports = [
    "${
      builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }
    }/framework/13-inch/7040-amd"
    # Include the results of the hardware scan.
    ./hardware-configuration-framework-13.nix
    # Include my configuration shared with all systems
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
    hostName = lib.mkForce "nixos-framework-13";
    useDHCP = lib.mkDefault true;
  };

  programs.steam.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  system.userActivationScripts.linktosharedfolders.text = ''
    if [[ ! -h "$HOME/git" ]]; then
      ln -s "/media/extra/git" "$HOME/git"
    fi
  '';
}
