{
  lib,
  nixos-hardware,
  ...
}:

{
  imports = [
    nixos-hardware.nixosModules.framework-13-7040-amd
    # Include the results of the hardware scan.
    ./hardware-configuration-framework-13.nix
    # Include my configuration shared with all systems
    ./base.nix
  ];

  powerManagement.cpuFreqGovernor = "schedutil";

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

  # Enable sound with pipewire.
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
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  systemd.services.battery-cycle-guard = {
    description = "Keep battery between 40% and 80% when plugged in";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "60s";
    };
    script = ''
      while true; do
        capacity=$(cat /sys/class/power_supply/BAT1/capacity)
        threshold=$(cat /sys/class/power_supply/BAT1/charge_control_end_threshold)

        if [ "$threshold" -ge 80 ] && [ "$capacity" -ge 80 ]; then
          echo 40 > /sys/class/power_supply/BAT1/charge_control_end_threshold
          echo "Stopped charging at $capacity%"
        elif [ "$threshold" -lt 80 ] && [ "$capacity" -le 41 ]; then
          echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold
          echo "Started charging at $capacity%"
        fi

        sleep 60
      done
    '';
  };

  system.userActivationScripts.linktosharedfolders.text = ''
    if [[ ! -h "$HOME/git" ]]; then
      ln -s "/media/extra/git" "$HOME/git"
    fi
  '';
}
