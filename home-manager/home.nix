{
  config,
  pkgs,
  nixmox,
  piperVoiceModels,
  ...
}:

let
  sunset-theme = nixmox.oomoxPlugins.theme-oomox.generate {
    name = "sunset-cave";
    src = ./theme/theme-file;
    gtkVariant = "all";
  };
  piper =
    # Custom piper without espeak-ng
    (
      pkgs.piper-tts.overrideAttrs (oldAttrs: {
        buildInputs = with pkgs; [
          onnxruntime
          spdlog
        ];
      })
    );

in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "chesedo";
  home.homeDirectory = "/home/chesedo";

  home.packages = with pkgs; [
    blugon

    discord
    slack

    jq
    jc

    playerctl

    trayer

    upwork

    xfce.thunar
    # Optionals
    xfce.xfconf # Needed to save the preferences
    xfce.exo # Used by default for `open terminal here`, but can be changed

    zoom-us

    sqlite
    marksman # For markdown files
    languagetool

    nodejs_20 # Needed for copilot emacs plugin

    podman-compose

    # To take screenshots
    slop
    shotgun
    (writeShellScriptBin "screenshot" (builtins.readFile ../scripts/screenshot.sh))

    # To manage the clipboard
    (writeShellScriptBin "clipboard" (builtins.readFile ../scripts/clipboard.sh))

    # Used by the eww app launcher
    (writeShellScriptBin "filter-executables" (builtins.readFile ../scripts/filter-executables.sh))

    # For TTS
    piper
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
      package = sunset-theme;
      name = "sunset-cave";
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    autorandr = {
      enable = true;
      hooks = {
        postswitch = {
          "notify-and-reload" = ''
            # On first login the default profile is loaded.
            # However, my monitors might be connected. This will mean the wrong profile is loaded.
            # So detect that and load the correct one if needed.
            detected=$(${pkgs.autorandr}/bin/autorandr --match-edid --detected)
            if [[ $detected != $AUTORANDR_CURRENT_PROFILE ]]; then
              ${pkgs.libnotify}/bin/notify-send "Incorrectly loaded $AUTORANDR_CURRENT_PROFILE display"
              ${pkgs.autorandr}/bin/autorandr --match-edid --load $detected &

              exit 0
            fi

            ${pkgs.libnotify}/bin/notify-send "Loaded $AUTORANDR_CURRENT_PROFILE display"

            # Leftvm might have loaded the wrong config or just seems to not have some keybindings after autorandr ran.
            # So reload it to make sure everything is correct.
            ${pkgs.leftwm}/bin/leftwm-command SoftReload
            ${pkgs.libnotify}/bin/notify-send "Reloaded leftwm"

          '';
        };
      };
      profiles = {
        "home" = {
          fingerprint = {
            small = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
            left = "00ffffffffffff0010acf4414c5133412221010380351e78eaf995a755549c260f5054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c45000f282100001e000000ff003339424b3750330a2020202020000000fc0044454c4c20533234323148530a000000fd00304b1e5310000a202020202020013b020321c149901f05141304030201230907078301000067030c000000001ee2000f011d8018711c1620582c2500c48e2100009e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075";
            right = "00ffffffffffff0010acf4414c3938392221010380351e78eaf995a755549c260f5054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c45000f282100001e000000ff004330424b3750330a2020202020000000fc0044454c4c20533234323148530a000000fd00304b1e5310000a202020202020014f020321c149901f05141304030201230907078301000067030c000000001ee2000f011d8018711c1620582c2500c48e2100009e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075";
          };
          config = {
            small = {
              enable = true;
              primary = true;
              position = "2471x1080";
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
        "default" = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          };
          config = {
            eDP-1 = {
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
      configDir = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/eww";
    };

    git = {
      enable = true;
      userName = "chesedo";
      userEmail = "pieter@chesedo.me";
      extraConfig = {
        core.askPass = "";
        rerere.enabled = true;
      };
      ignores = [
        ".direnv/"
        ".envrc"
        ".ccls-cache/"
        "compile_commands.json"
      ];
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

    starship = {
      enable = true;
      settings = {
        add_newline = true;

        character = {
          success_symbol = "❯";
          error_symbol = "❯";
          vimcmd_symbol = "❮";
        };

        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          read_only = " 󰌾";
        };

        rust = {
          format = "via [$symbol($version )]($style)";
          symbol = "󱘗 ";
        };

        cmd_duration = {
          min_time = 2000;
        };

        time = {
          disabled = false;
          format = "[$time]($style) ";
          time_format = "%H:%M";
        };

        # Copied from the nerd-font presents
        # https://starship.rs/presets/nerd-font
        aws.symbol = "  ";
        buf.symbol = " ";
        c.symbol = " ";
        conda.symbol = " ";
        crystal.symbol = " ";
        dart.symbol = " ";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        fennel.symbol = " ";
        fossil_branch.symbol = " ";
        git_branch.symbol = " ";
        git_commit.tag_symbol = "  ";
        golang.symbol = " ";
        guix_shell.symbol = " ";
        haskell.symbol = " ";
        haxe.symbol = " ";
        hg_branch.symbol = " ";
        hostname.ssh_symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        kotlin.symbol = " ";
        lua.symbol = " ";
        memory_usage.symbol = "󰍛 ";
        meson.symbol = "󰔷 ";
        nim.symbol = "󰆥 ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";
        ocaml.symbol = " ";
        package.symbol = "󰏗 ";
        perl.symbol = " ";
        php.symbol = " ";
        pijul_channel.symbol = " ";
        python.symbol = " ";
        rlang.symbol = "󰟔 ";
        ruby.symbol = " ";
        scala.symbol = " ";
        swift.symbol = " ";
        zig.symbol = " ";
        gradle.symbol = " ";

        os.symbols = {
          Alpaquita = " ";
          Alpine = " ";
          AlmaLinux = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌 ";
          Illumos = "󰈸 ";
          Kali = " ";
          Linux = " ";
          Mabox = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = "󰈺 ";
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          RockyLinux = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Void = " ";
          Windows = "󰍲 ";
        };
      };
    };

    zsh = {
      defaultKeymap = "viins";
      enable = true;
      localVariables = {
        # Put you-should-use in hardcore mode
        YSU_HARDCORE = 1;
      };
      initContent = ''
        # Prevent any direnv output
        export DIRENV_LOG_FORMAT=""
      '';
      plugins = [
        {
          name = "you-should-use";
          src = pkgs.zsh-you-should-use;
          file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
        }
      ];
      shellAliases = {
        c = "cargo";
        cw = "cargo watch -q -c";
        p = "podman";
        pc = "podman-compose";
      };
    };
  };

  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          font = "FiraCode Nerd Font 10";
          frame_width = 2;
          frame_color = "#E8846C";

          separator_color = "frame";
          separator_height = 2;

          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;

          corner_radius = 10;

          background = "#1A1A1D";
          foreground = "#E6DDD1";
        };

        urgency_low = {
          background = "#2C3241";
          foreground = "#E6DDD1";
          frame_color = "#465366";
          timeout = 10;
        };

        urgency_normal = {
          background = "#2C3241";
          foreground = "#E6DDD1";
          frame_color = "#E8846C";
          timeout = 10;
        };

        urgency_critical = {
          background = "#1A1A1D";
          foreground = "#E6DDD1";
          frame_color = "#E8846C";
          timeout = 0;
        };
      };
    };
  };

  xdg.configFile = {
    "alacritty/alacritty.toml".source = ../alacritty.toml;
    "blugon/config".source = ./blugon/config;
    "leftwm".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/leftwm";
    "speech-dispatcher/speechd.conf".text = ''
      AddModule "piper-tts-generic" "sd_generic" "piper-tts-generic.conf"
      DefaultModule   piper-tts-generic
    '';
    "speech-dispatcher/modules/piper-tts-generic.conf".text = ''
      GenericExecuteSynth "echo \"$DATA\" | ${piper}/bin/piper --model ${piperVoiceModels.en-us-ryan-high}/share/piper/voices/en_US/ryan/high/en_US-ryan-high.onnx --output_raw --quiet | ${pkgs.pipewire}/bin/pw-play --rate 22050 --channel-map LE --raw -"

      AddVoice "en-US" "male1" "en_US-ryan-high"
    '';
  };

  home.file = {
    ".doom.d" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.doom.d";
      onChange = "EMACS=${pkgs.emacs}/bin/emacs ~/.config/emacs/bin/doom sync";
    };
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Amber";
    size = 20;
    gtk.enable = true;
    x11.enable = true;
  };
}
