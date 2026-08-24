{
  config,
  lib,
  pkgs,
  piperVoiceModels,
  voxtype,
  ...
}:

let
  secrets = import (builtins.toPath (builtins.getEnv "HOME" + "/dotfiles/home-manager/secrets.nix"));
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
    gh

    playerctl

    trayer

    upwork

    thunar
    # Optionals
    xfconf # Needed to save the preferences
    xfce4-exo # Used by default for `open terminal here`, but can be changed

    zoom-us

    sqlite
    marksman # For markdown files
    languagetool

    nodejs_24 # Needed for copilot emacs plugin

    podman-compose

    # To take screenshots
    slop
    shotgun
    (writeShellScriptBin "screenshot" (builtins.readFile ../scripts/screenshot.sh))

    # To manage the clipboard
    (writeShellScriptBin "clipboard" (builtins.readFile ../scripts/clipboard.sh))

    # Used by the eww app launcher
    (writeShellScriptBin "filter-executables" (builtins.readFile ../scripts/filter-executables.sh))

    # Notification scripts
    (pkgs.writeShellScriptBin "dunst-update-eww" (builtins.readFile ../scripts/dunst-update-eww.sh))
    (writeShellScriptBin "clear-app-notifications" (
      builtins.readFile ../scripts/clear-app-notifications.sh
    ))

    # For TTS
    piper-tts

    # jiratui patched for textual 8.x compat (Select.BLANK no longer valid; use .clear())
    (pkgs.jiratui.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        sed -i 's/\(self\.[a-z_]*selector\)\.value = Select\.BLANK/\1.clear()/g' \
          src/jiratui/widgets/work_item_details/details.py
      '';
    }))

    # Because google meets is slow when there are many participants, we use chrome instead which has hardware acceleration for VP9 codec.
    google-chrome
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  stylix = {
    enable = true;
    base16Scheme = import ./theme/alpine-dusk.nix;
    image = ../leftwm/themes/current/background.jpg;
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Propo";
      };
      serif = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Propo";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        desktop = 10;
        terminal = 12;
        popups = 10;
      };
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      light = "Papirus-Dark";
      dark = "Papirus-Dark";
    };

    opacity.terminal = 0.95;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          dynamic_padding = true;
        };
        bell = {
          animation = "EaseOutExpo";
          color = "#ffffff";
          duration = 300;
        };
      };
    };

    autorandr = {
      enable = true;
      hooks = {
        postswitch = {
          "log-profile" = ''
            logger -t autorandr-hook "postswitch fired: profile=$AUTORANDR_CURRENT_PROFILE"
          '';
        };
      };
      profiles = {
        "home" = {
          fingerprint = {
            small = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
            left = "00ffffffffffff0010acf4414c3938392221010380351e78eaf995a755549c260f5054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c45000f282100001e000000ff004330424b3750330a2020202020000000fc0044454c4c20533234323148530a000000fd00304b1e5310000a202020202020014f020321c149901f05141304030201230907078301000067030c000000001ee2000f011d8018711c1620582c2500c48e2100009e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075";
            middle = "00ffffffffffff0010ac394257323242221f0104a53c22783b2176a9534494231c4d5aa54b00d100d1c0b300a94081808100714f0101565e00a0a0a029503020350055502100001a000000ff00445738485a38330a2020202020000000fc0044454c4c20533237323244474d000000fd0030a5fafa41010a2020202020200150020325f14a3f101f0413121103020123090707830100006d1a0000020130a5000000000000f4fb0050a0a028500820680055502100001aa7e5007ea0a050500820680055502100001a6fc200a0a0a055503020350055502100001a000000000000000000000000000000000000000000000000000000000000000000000000f4";
            right = "00ffffffffffff0010acf4414c5133412221010380351e78eaf995a755549c260f5054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c45000f282100001e000000ff003339424b3750330a2020202020000000fc0044454c4c20533234323148530a000000fd00304b1e5310000a202020202020013b020321c149901f05141304030201230907078301000067030c000000001ee2000f011d8018711c1620582c2500c48e2100009e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075";
          };
          config = {
            small = {
              enable = true;
              primary = true;
              position = "4096x1080";
              mode = "2256x1504";
              rate = "60.00";
              rotate = "normal";
              scale = {
                x = 0.5;
                y = 0.5;
              };
            };
            left = {
              enable = true;
              position = "0x0";
              mode = "1920x1080";
              rate = "74.97";
              rotate = "normal";
            };
            middle = {
              enable = true;
              position = "1920x0";
              mode = "2560x1440";
              rate = "165.08";
              rotate = "normal";
              scale = {
                x = 0.85;
                y = 0.85;
              };
            };
            right = {
              enable = true;
              position = "4096x0";
              mode = "1920x1080";
              rate = "74.97";
              rotate = "normal";
            };
          };
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
                x = 0.5;
                y = 0.5;
              };
            };
          };
        };
      };
    };

    claude-code = {
      enable = true;
      context = ./claude/AGENTS.md;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eww.enable = true;

    git = {
      enable = true;
      ignores = [
        ".direnv/"
        ".envrc"
        ".ccls-cache/"
        "compile_commands.json"
      ];
      settings = {
        core.askPass = "";
        rerere.enabled = true;
        user = {
          email = "pieter@chesedo.me";
          name = "chesedo";
        };
        github.user = "chesedo";
      };
      signing = {
        key = "C53FA3689310ED6A!"; # *663
        signByDefault = true;
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "WSL" = {
          hostname = "wsl";
          user = "pieter";
          port = 2222;
          forwardAgent = true;
        };
      };
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

    voxtype = {
      enable = true;
      package = voxtype.default;
      service.enable = true;
      settings = {
        output.mode = "clipboard";
        hotkey = {
          enabled = true;
          key = "RIGHTCTRL";
        };
        audio.device = "sysdefault:CARD=Generic_1";
        whisper = {
          mode = "remote";
          remote_endpoint = "http://wsl:8080";
        };
        status = {
          icon_theme = "nerd-font";
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

        rust-init() {
          if [[ -f .envrc ]]; then
            echo "rust-init: .envrc already exists — refusing to overwrite" >&2
            return 1
          fi
          echo 'use flake ~/dotfiles#rust' > .envrc
          direnv allow
        }
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
        jt = "jiratui ui -p MOD -u 712020:3cb3242f-6941-4a62-8d26-93ddb13e489f";
      };
    };
  };

  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          frame_width = 2;
          # colors injected by Stylix

          separator_height = 2;

          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;

          corner_radius = 10;
        };

        urgency_low.timeout = 10;
        urgency_normal.timeout = 10;
        urgency_critical.timeout = 0;
      };
    };
  };

  xdg.configFile = {
    # leftwm has built-in XDG autostart support (leftwm::utils::autostart in the
    # binary) and runs .desktop Exec= commands directly at login, bypassing
    # systemd. The system autorandr entry uses `-c --default default` which lacks
    # --match-edid and loads the wrong profile. This override fixes the command.
    # If leftwm ever drops this feature, verify with:
    #   strings $(which leftwm) | grep autostart
    "autostart/autorandr.desktop".text = ''
      [Desktop Entry]
      Name=Autorandr
      Exec=${pkgs.autorandr}/bin/autorandr --change --match-edid --skip-options gamma
      Type=Application
    '';

    "blugon/config".source = ./blugon/config;
    "leftwm".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/leftwm";
    "eww".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/eww";
    "speech-dispatcher/speechd.conf".text = ''
      AddModule "piper-tts-generic" "sd_generic" "piper-tts-generic.conf"
      DefaultModule   piper-tts-generic
    '';
    "speech-dispatcher/modules/piper-tts-generic.conf".text = ''
      GenericExecuteSynth "echo \"$DATA\" | ${pkgs.piper-tts}/bin/piper --model ${piperVoiceModels.en-us-ryan-high}/share/piper/voices/en_US/ryan/high/en_US-ryan-high.onnx --output_raw --quiet | ${pkgs.pipewire}/bin/pw-play --rate 22050 --channel-map LE --raw -"

      AddVoice "en-US" "male1" "en_US-ryan-high"
    '';
    "jiratui/config.yaml".text = ''
      jira_api_username: 'pieter.engelbrecht@redis.com'
      jira_api_token: '${secrets.jiraApiToken}'
      jira_api_base_url: 'https://redislabs.atlassian.net'
    '';
  };

  home.file = {
    ".doom.d" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.doom.d";
      onChange = "EMACS=${pkgs.emacs}/bin/emacs ~/.config/emacs/bin/doom sync";
    };
    ".cargo/config.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.cargo/config.toml";
    };
    # settings.json must stay strict JSON, so the two sandbox keys are noted
    # here (the hooks key is covered further down):
    #   filesystem.allowWrite — the sandbox filesystem is read-only apart from
    #     an allowlist. npx needs ~/.npm, cargo needs its registry and git
    #     caches for crates it has not downloaded, and ~/.cache covers the rest
    #     of the tooling. /tmp/rltest_portfile.lock is RLTest's hardcoded
    #     port-allocation lock, so RediSearch flow tests cannot start under the
    #     sandbox without it. An entry whose path does not exist is dropped
    #     silently, and systemd-tmpfiles sweeps /tmp, so `touch` it again if the
    #     tests start failing with EROFS.
    #   excludedCommands — nix reaches nix-daemon over a unix socket, which the
    #     sandbox's seccomp filter blocks, so store operations die with "cannot
    #     create Unix domain socket". Matching needs nix as the head of a
    #     sub-command: `cd x && nix build` matches, but nesting it inside a
    #     brace group or another program can defeat the match — the symptom is
    #     the socket error above. A match exempts the whole invocation, so
    #     anything chained alongside it runs unsandboxed too. Do not reach
    #     for network.allowAllUnixSockets instead: it is
    #     all-or-nothing on Linux, exposing the session D-Bus (a systemd-run
    #     escape), and it would let a sandboxed process have nix-daemon fetch
    #     arbitrary URLs, making allowedDomains decorative. Deliberately given
    #     no permissions.allow entries either: excluding these commands already
    #     drops the sandbox, and `nix run` and friends execute arbitrary code,
    #     so leave the approval step in place.
    # mkOutOfStoreSymlink points at this working tree, so edits to any target
    # in this block are live; only adding a declaration needs a switch.
    ".claude/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home-manager/claude/settings.json";
    };
    ".claude/statusline-command.sh" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home-manager/claude/statusline.sh";
    };
    # Populates submodules in agent worktrees; rationale in the script header.
    # Wired to both events because only SubagentStart fires for a subagent,
    # while SessionStart covers a session started directly in a worktree.
    # Hooks run unsandboxed, so the script is deliberately offline-only: it
    # populates from objects already on disk and reports anything missing rather
    # than fetching with real credentials on every session.
    #
    # Not WorktreeCreate: that event is a provider, expected to create the
    # worktree and echo its path, so a hook printing nothing breaks every
    # worktree creation.
    ".claude/scripts/worktree-submodules.sh" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home-manager/claude/worktree-submodules.sh";
    };
  };

  home.activation.generateEwwColors =
    let
      c = config.lib.stylix.colors;
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cat > ${config.home.homeDirectory}/dotfiles/eww/colors.scss << 'EOF'
      // Generated from home-manager/theme/alpine-dusk.yaml — do not edit manually
      $theme-bg:        #${c.base00};
      $theme-bg-alt:    #${c.base01};
      $theme-fg:        #${c.base05};
      $theme-accent:    #${c.base0E};
      $theme-muted:     #${c.base04};
      $theme-highlight: #${c.base0D};
      $theme-border:    #${c.base02};
      $theme-warn:      #${c.base0A};
      $shadow:          #${c.base00};
      EOF
    '';
}
