{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "chesedo";
  home.homeDirectory = "/home/chesedo";

  home.packages = with pkgs; [
    blugon

    gimp-with-plugins

    hicolor-icon-theme

    krita
    inkscape

    podman-compose

    playerctl

    trayer

    upwork

    xfce.thunar
    # Optionals
    xfce.xfconf # Needed to save the preferences
    xfce.exo # Used by default for `open terminal here`, but can be changed

    zoom-us
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

    git = {
      enable = true;
      userName  = "chesedo";
      userEmail = "pieter@chesedo.me";
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
        pc = "podman-compose";
      };
    };
  };

  services.picom = {
    enable = true;
    fade = true;
    noDockShadow = false;
    shadow = true;
  };

  xdg.configFile = {
    "blugon/config".source = ./blugon/config;
  };

  xsession.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata_Ice";
    size = 24;
  };
}
