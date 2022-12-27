{ config, pkgs, ... }:
let
  # My custom node packages.
  # Run `node2nix -i ./node-packages.json -o node-packages.nix` in the folder to update
  # Then manually update any special character packages in node-packages.nix
  # https://kcode.co.za/install-npm-packages-on-nixos-with-node2nix/
  # https://code-notes.jhuizy.com/add-custom-npm-to-home-manager/
  customNodePackages = pkgs.callPackage ./customNodePackages {};
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "chesedo";
  home.homeDirectory = "/home/chesedo";

  home.packages = with pkgs; [
    blugon

    discord

    gimp-with-plugins

    hicolor-icon-theme

    jq

    krita
    inkscape

    playerctl

    trayer

    upwork

    xfce.thunar
    # Optionals
    xfce.xfconf # Needed to save the preferences
    xfce.exo # Used by default for `open terminal here`, but can be changed

    zoom-us

    wordnet
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.tela-icon-theme;
      name = "Tela-blue";
    };
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eww = {
      enable = true;
      configDir = ../leftwm/themes/current/eww-bar;
    };

    git = {
      enable = true;
      userName  = "chesedo";
      userEmail = "pieter@chesedo.me";
      extraConfig = {
        core.askPass = "";
      };
    };

    ssh = {
      enable = true;
      matchBlocks = {
        "runner.shuttle" = {
          hostname = "runner.shuttle.rs";
          user = "ubuntu";
          forwardAgent = true;
        };
      };
    };

    zsh = {
      enable =true;
      initExtraFirst = ''
        source ~/.p10k.zsh
      '';
      localVariables = {
        # Put you-should-use in hardcore mode
        YSU_HARDCORE = 1;
      };
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "you-should-use";
          src = pkgs.zsh-you-should-use;
          file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
        }
      ];
      shellAliases = {
        p = "podman";
      };
    };
  };

  xdg.configFile = {
    "alacritty/alacritty.yml".source = ../alacritty.yml;
    "blugon/config".source = ./blugon/config;
    "leftwm".source = ../leftwm;
    "inkscape/palettes".source = ./inkscape/palettes;
  };

  home.file = {
    ".p10k.zsh".source = ../.p10k.zsh;
    ".doom.d" = {
      source = ../.doom.d;
      onChange = "~/.emacs.d/bin/doom sync";
    };
  };

  xsession.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata_Ice";
    size = 24;
  };
}
