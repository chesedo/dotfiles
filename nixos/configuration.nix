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
 # This configuration worked on 09-03-2021 nixos-unstable @ commit 102eb68ceec
 # The image used https://hydra.nixos.org/build/134720986

  imports = [
    <nixos-hardware/raspberry-pi/4>
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
  };

  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
    dtparam=sd_poll_once=on
  '';

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "nixos-raspi-4"; # Define your hostname.
    networkmanager = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    fd
    ripgrep
    gcc

    alacritty
    feh
    dmenu
    eww
    libnotify

    firefox
    htop
    home-manager

    newMyxer
  ];

  fonts.fonts = with pkgs; [
    powerline
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users.root = {
      password = "apassword";
    };
    users.chesedo = {
      isNormalUser = true;
      password = "apassword";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };
  };

  environment.variables = {
    EDITOR = "nvim";
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

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "colemak";
    xkbOptions = "caps:swapescape";
    displayManager.lightdm.enable = true;
    windowManager.leftwm.enable = true;
  };
  
  powerManagement.cpuFreqGovernor = "ondemand";
  system.stateVersion = "21.05";
  #swapDevices = [ { device = "/swapfile"; size = 3072; } ];
}
