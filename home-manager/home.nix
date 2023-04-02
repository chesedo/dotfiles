{ config, pkgs, ... }:

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

    xfce.thunar
    # Optionals
    xfce.xfconf # Needed to save the preferences
    xfce.exo # Used by default for `open terminal here`, but can be changed

    zoom-us

    wordnet
    ltex-ls # For text files
    sqlite
    marksman # For markdown files
    languagetool
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

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
      userName = "chesedo";
      userEmail = "pieter@chesedo.me";
      extraConfig = { core.askPass = ""; };
      signing = {
        key = "5E90934750BE7A42";
        signByDefault = true;
      };
    };

    ssh = {
      enable = true;
      matchBlocks = {
        "3.11.51.209" = { user = "ec2-user"; };
        "*.shuttle.internal" = {
          user = "ec2-user";
          proxyJump = "3.11.51.209";
          forwardAgent = true;
        };
        "18.132.154.166" = { user = "ec2-user"; };
        "*.shuttle.prod.internal" = {
          user = "ec2-user";
          proxyJump = "18.132.154.166";
        };
        "metrics.shuttle" = {
          hostname = "13.40.57.159";
          user = "ec2-user";
          forwardAgent = true;
        };
      };
    };

    zsh = {
      defaultKeymap = "viins";
      enable = true;
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
      shellAliases = { p = "podman"; };
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
