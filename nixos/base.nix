{
  config,
  pkgs,
  lib,
  options,
  zen-browser,
  ...
}:

{
  boot.loader.grub.enable = false;

  environment = {
    # Prevent readies from trying to modify /etc/profile by adding profile.d comment
    etc."profile".text = lib.mkAfter ''

      # This comment contains 'profile.d' to prevent readies/getpy3 from modifying /etc/profile
      # Since we're using Nix, we don't need the profile.d system modifications
    '';

    systemPackages = with pkgs; [
      fd
      ripgrep
      gcc
      wl-clipboard
      emacs

      alacritty
      imv # Wayland image viewer, replaces feh

      # No blueman or pwvucontrol: DMS's control centre manages Bluetooth
      # (BluetoothService.qml) and audio devices (AudioService.qml) natively,
      # and nothing in DMS shells out to either. Add one back if a device ever
      # needs manual profile switching or per-application routing, which the
      # control centre does not cover.
      htop
      home-manager

      zen-browser

      pinentry-qt

      proselint # For emacs linting
      (python3.withPackages (p: with p; [ grip ])) # To preview markdown and org files

      yubioath-flutter
    ];

    variables = {
      EDITOR = "emacs";
    };
  };

  fonts.packages = with pkgs; [
    powerline
    nerd-fonts.fira-code
    symbola # To fix emacs ligatures
  ];

  hardware = {
    bluetooth.enable = true;
    gpgSmartcards.enable = true;
  };

  networking = {
    networkmanager.enable = true;
    hosts = {
      "192.168.10.70" = [ "wsl" ];
    };
  };

  nix = {
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    dconf.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
      enableSSHSupport = true;
    };
    udevil.enable = true; # Mount drives without sudo
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [
          "z"
          "git"
          "git-auto-fetch"
        ];
      };
    };
  };

  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
    devmon.enable = true; # Auto mount external drives
    openssh.enable = true;
    # Required by DMS, and not enabled by its Nix modules: the battery widget,
    # popout, control centre detail, power profile modal and OSD all drive
    # Quickshell.Services.UPower. Without it there is no battery UI at all.
    upower.enable = true;
  };

  system.userActivationScripts.linkhomemanager.text = ''
    if [[ ! -d "$HOME/.config/nixpkgs" ]]; then
      mkdir -p "$HOME/.config/nixpkgs"
      ln -s "$HOME/dotfiles/home-manager/home.nix" "$HOME/.config/nixpkgs"
    fi
  '';

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users.chesedo = {
      isNormalUser = true;
      description = "Pieter";
      initialPassword = "apassword";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input" # Required for voxtype evdev hotkey grabbing
      ];
    };
  };

  virtualisation.podman.enable = true;
}
