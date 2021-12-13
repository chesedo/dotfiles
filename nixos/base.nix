{ config, pkgs, lib, ... }:

# Patch until the following PR is merged
# https://github.com/VixenUtils/Myxer/pull/20
let newMyxer = pkgs.myxer.overrideAttrs (old: {
  src = pkgs.fetchFromGitHub {
    owner = "ErinvanderVeen";
    repo = "Myxer";
    rev = "gio-version";
    sha256 = "w1MX8igx/ptrG9eW+EfZreB+6Cj8EpZgED199FrGg+c=";
  };
  version = "1.2.1-gio-version-patch";
  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    src = pkgs.fetchFromGitHub {
      owner = "ErinvanderVeen";
      repo = "Myxer";
      rev = "gio-version";
      sha256 = "w1MX8igx/ptrG9eW+EfZreB+6Cj8EpZgED199FrGg+c=";
    };
    outputHash = "jftu5aiZzxjhrsSrhWDaqF1CwHyeZxXhFbGnTv9qTy4=";
  });
});

in {
  boot.loader.grub.enable = false;

  environment = {
    systemPackages = with pkgs; [
      neovim
      fd
      ripgrep
      gcc

      alacritty
      feh
      dmenu
      eww

      libnotify
      dunst

      firefox
      htop
      home-manager

      newMyxer
    ];

    variables = {
      EDITOR = "nvim";
    };
  };

  fonts.fonts = with pkgs; [
    powerline
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
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
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.zsh = {
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

  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
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
}