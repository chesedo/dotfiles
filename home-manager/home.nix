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
    jc

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

    nodejs_20 # Needed for copilot emacs plugin

    podman-compose
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
    autorandr = {
      enable = true;
      profiles = {
        "home" = {
          fingerprint = {
            center =
              "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
            left =
              "00ffffffffffff0010acf4414c5133412221010380351e78eaf995a755549c260f5054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c45000f282100001e000000ff003339424b3750330a2020202020000000fc0044454c4c20533234323148530a000000fd00304b1e5310000a202020202020013b020321c149901f05141304030201230907078301000067030c000000001ee2000f011d8018711c1620582c2500c48e2100009e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075";
            right =
              "00ffffffffffff0010acf4414c3938392221010380351e78eaf995a755549c260f5054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c45000f282100001e000000ff004330424b3750330a2020202020000000fc0044454c4c20533234323148530a000000fd00304b1e5310000a202020202020014f020321c149901f05141304030201230907078301000067030c000000001ee2000f011d8018711c1620582c2500c48e2100009e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075";
          };
          config = {
            center = {
              enable = true;
              primary = true;
              position = "2100x1080";
              mode = "2256x1504";
              rate = "60.00";
              rotate = "normal";
              scale = {
                x = 0.5625;
                y = 0.5625;
              };
            };
            left = {
              enable = true;
              position = "0x0";
              mode = "1920x1080";
              rate = "60.00";
              rotate = "normal";
            };
            right = {
              enable = true;
              position = "1920x0";
              mode = "1920x1080";
              rate = "60.00";
              rotate = "normal";
            };
          };
          hooks.postswitch = "${builtins.readFile ./setup-home-display.sh}";
        };
        "laptop-only" = {
          fingerprint = {
            screen =
              "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          };
          config = {
            screen = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "2256x1504";
              rate = "60.00";
              rotate = "normal";
              scale = {
                x = 0.5625;
                y = 0.5625;
              };
            };
          };
        };
      };
    };

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
        # key = "54D3C507CD48CF48!"; # *661
        key = "E09D145B50F15F0A!"; # *663
        signByDefault = true;
      };
    };

    ssh = {
      enable = true;
      matchBlocks = { };
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
      shellAliases = {
        c = "cargo";
        cc = "cargo clippy";
        cw = "cargo watch -q -c";
        d = "docker";
        dc = "docker compose";
        p = "podman";
        pc = "podman-compose";
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
