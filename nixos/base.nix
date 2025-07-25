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
      xclip
      emacs

      alacritty
      feh
      picom

      libnotify

      blueberry
      htop
      home-manager
      pavucontrol

      firefox
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
    hostName = "nixos";
    networkmanager.enable = true;
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
    clipcat.enable = true; # Clipboard manager
    devmon.enable = true; # Auto mount external drives
    openssh.enable = true;
    upower.enable = true; # See power information about devices
    displayManager.defaultSession = "none+leftwm";
    libinput.touchpad = {
      accelSpeed = "0.5";
      naturalScrolling = true;
    };
    xserver = {
      enable = true;
      displayManager.lightdm.greeters.mini = {
        enable = true;
        user = "chesedo";
        extraConfig = ''
          [greeter]
          show-password-label = false
          invalid-password-text = Invalid Password
          show-input-cursor = true
          password-alignment = center

          [greeter-hotkeys]
          mod-key = meta
          shutdown-key = s
          restart-key = r
          hibernate-key = h
          suspend-key = u

          [greeter-theme]
          font = "FiraCode Nerd Font"
          font-size = 1em
          font-weight = bold
          font-style = normal
          text-color = "#E6DDD1"
          error-color = "#E8846C"
          background-color = "#1A1A1D"
          background-image = ""
          layout-space = 0
          password-color = "#E6DDD1"
          password-background-color = "#2C3241"
          password-border-color = "#E8846C"
          password-border-width = 1
        '';
      };
      xkb = {
        layout = "us";
        options = "caps:escape";
        variant = "colemak";
      };
      windowManager.leftwm.enable = true;
    };
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
      ];
    };
  };

  virtualisation.podman.enable = true;
}
