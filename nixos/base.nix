{ config, pkgs, lib, options, ... }:

{
  boot.loader.grub.enable = false;

  environment = {
    systemPackages = with pkgs; [
      fd
      ripgrep
      gcc
      xclip
      emacs

      alacritty
      feh
      dmenu

      libnotify
      dunst

      blueberry
      firefox
      htop
      home-manager
      nodePackages.node2nix

      spideroak

      myxer
    ];

    variables = {
      EDITOR = "emacs";
    };
  };

  fonts.fonts = with pkgs; [
    arphic-uming # For Chinese
    powerline
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
  };

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ libpinyin uniemoji ];
  };

  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
    };
  };

  nix = {
    autoOptimiseStore = true;
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
    nixPath = options.nix.nixPath.default ++
    # Append our nixpkgs-overlays.
    [ "nixpkgs-overlays=/etc/nixos/overlays" ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import overlays/myxer-overlay.nix)
      (import overlays/leftwm-overlay.nix)
    ];
  };

  programs = {
    dconf.enable = true;
    ssh.startAgent = true;
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
    xserver = {
      enable = true;
      displayManager.defaultSession = "none+leftwm";
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
          font = Sans
          font-size = 1em
          font-weight = bold
          font-style = normal
          text-color = "#88c0d0"
          error-color = "#bf616a"
          background-color = "#2e3440"
          window-color = "#88c0d0"
          border-color = "#d8dee9"
          border-width = 0
          layout-space = 1
          password-color = "#88c0d0"
          password-background-color = "#434c5e"
          password-border-color = "#d8dee9"
          password-border-width = 0
        '';
      };
      layout = "us";
      xkbVariant = "colemak";
      xkbOptions = "caps:swapescape";
      windowManager.leftwm.enable = true;
    };
  };

  sound.enable = true;

  system.userActivationScripts.linkhomemanager.text = ''
  if [[ ! -d "$HOME/.config/nixpkgs" ]]; then
    mkdir -p "$HOME/.config/nixpkgs"
    ln -s "$HOME/git/dotfiles/home-manager/home.nix" "$HOME/.config/nixpkgs"
  fi
  '';

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users.chesedo = {
      isNormalUser = true;
      password = "apassword";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.dnsname.enable = true;
  };
}
