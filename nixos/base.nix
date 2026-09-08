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
      # emacs-pgtk rather than emacs: the default build is X11 only, so under
      # niri it runs through xwayland-satellite, which gives every X11 client
      # one global scale (the smallest, on mixed outputs) by way of Xft/DPI and
      # Gdk XSETTINGS. doom-font sidesteps all of that -- an integer :size is a
      # pixel size -- so 12 stayed 12 physical pixels and Emacs came out tiny on
      # the 201 PPI laptop panel while looking right on the 92 PPI externals.
      # The pure-GTK build is a native Wayland client and takes the per-output
      # scale instead. GTK3 has no fractional scaling, so at eDP-1's 1.5 it
      # renders at scale 2 and lets niri downscale: right size, marginally soft.
      emacs-pgtk

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

      # The dialog is drawn by gcr's prompter, which is GTK and so
      # wayland-native; this binary is only a D-Bus client for it.
      # programs.gnupg puts gcr on the session bus for gnome3-flavoured
      # pinentries, so the prompt works with gnome-keyring off.
      pinentry-gnome3

      proselint # For emacs linting
      (python3.withPackages (p: with p; [ grip ])) # To preview markdown and org files

    ];

    variables = {
      EDITOR = "emacs";
    };
  };

  fonts = {
    packages = with pkgs; [
      powerline
      nerd-fonts.fira-code
      symbola # To fix emacs ligatures
    ];

    # Without this, generic families still resolve to DejaVu, so anything
    # asking for plain sans-serif looks nothing like the shell. Inter and Fira
    # Code are already present -- the dms-greeter module contributes both, and
    # the Noto families come from enableDefaultPackages -- so this only sets
    # the preference.
    #
    # Inter matches what DMS uses for its own UI (fontFamily "Inter Variable",
    # monoFontFamily "Fira Code"). Serif is a real serif rather than another
    # copy of the sans.
    fontconfig.defaultFonts = {
      sansSerif = [ "Inter" ];
      serif = [ "Noto Serif" ];
      monospace = [ "FiraCode Nerd Font Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

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
      pinentryPackage = pkgs.pinentry-gnome3;
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
