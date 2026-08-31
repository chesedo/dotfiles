{
  lib,
  pkgs,
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
    hostName = "nixos-framework-13";
    useDHCP = lib.mkDefault true;
  };

  # Label this generation in the boot menu so it is obvious which desktop a
  # given entry boots into.
  system.nixos.tags = [ "dms" ];

  programs.niri.enable = true;

  # DMS normally gets these from its own NixOS module, which is not in use here
  # because the shell itself is configured through home-manager. Without
  # accounts-daemon the user tile in the shell and the greeter stays empty.
  services.accounts-daemon.enable = true;

  services.displayManager = {
    # Redundant with the mkDefault programs.niri sets, and the DMS greeter
    # remembers the last session itself rather than reading this. Kept as the
    # explicit fallback for autologin and for any second session package later.
    defaultSession = "niri";

    # DankMaterialShell's own greeter, running on greetd inside a nested niri.
    dms-greeter = {
      enable = true;

      # Pulls the wallpaper and theme out of ~/.config + ~/.local/state at
      # greetd start, so the login screen matches the session.
      configHome = "/home/chesedo";

      compositor = {
        name = "niri";
        # The greeter's nested niri does not read the session's niri config,
        # so the keyboard layout has to be repeated -- without it the password
        # prompt is US QWERTY while the session is Colemak.
        customConfig = ''
          input {
              keyboard {
                  xkb {
                      layout "us"
                      variant "colemak"
                      options "caps:escape"
                  }
              }
          }
        '';
      };
    };
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

  # The battery charge band lives in the batteryGuard DMS plugin now, not in a
  # shell loop here. The plugin tracks explicitly whether it is filling toward
  # the upper limit or coasting down to the lower one, rather than inferring
  # that from whatever the threshold currently reads -- which broke as soon as
  # anything else wrote the file.
  #
  # It writes the threshold directly, so the attribute has to be group
  # writable. udev rather than tmpfiles because this has to survive the battery
  # re-enumerating, not just apply once at boot.
  #
  # Matching change as well as add costs a couple of coreutils invocations on
  # battery and AC transitions, and buys the permission being re-applied if the
  # attribute ever shows up after the add event. To apply without rebooting:
  # `udevadm trigger --subsystem-match=power_supply --action=change`.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="BAT?", ACTION=="add|change", \
      TEST=="charge_control_end_threshold", \
      RUN+="${pkgs.coreutils}/bin/chgrp wheel /sys/%p/charge_control_end_threshold", \
      RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/%p/charge_control_end_threshold"
  '';

  system.userActivationScripts.linktosharedfolders.text = ''
    if [[ ! -h "$HOME/git" ]]; then
      ln -s "/media/extra/git" "$HOME/git"
    fi
  '';
}
