{
  config,
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
    discord
    slack

    jq
    jc
    gh

    playerctl

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

    # Screenshots, clipboard history, the app launcher and notifications are
    # all DMS built-ins now, so the scripts that backed them are no longer
    # installed. The files themselves still sit in scripts/ -- see TODO.md.

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

  nixpkgs.config.allowUnfree = true;

  programs = {
    alacritty = {
      enable = true;
      settings = {
        # Written by DMS matugen whenever the theme changes. Until DMS has
        # generated it once, alacritty complains about the missing import on
        # every launch.
        general.import = [ "~/.config/alacritty/dank-theme.toml" ];

        font = {
          normal.family = "FiraCode Nerd Font Mono";
          size = 12;
        };

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

    claude-code = {
      enable = true;
      context = ./claude/AGENTS.md;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    dank-material-shell = {
      enable = true;

      # Runs `dms run --session` from a user unit bound to
      # graphical-session.target, which niri-session activates.
      systemd.enable = true;

      # Pinned to the nixpkgs build rather than the flake's own. The greeter is
      # configured at the NixOS layer, where the package defaults to
      # pkgs.dms-shell -- without this the login screen and the session run two
      # different builds of DMS against the same settings files. Comes from the
      # binary cache as a bonus.
      package = pkgs.dms-shell;

      # enableSystemMonitoring / enableVPN / enableDynamicTheming /
      # enableAudioWavelength / enableCalendarEvents all default to true, and
      # enableClipboardPaste is a documented no-op, so none are restated here.

      # Deliberately left unset: settings/clipboardSettings/session are written
      # as read-only store symlinks when non-empty, which stops DMS's own
      # Settings panel from saving. Configure through the GUI instead, and only
      # move things here once they have settled.
    };

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

  wayland.windowManager.niri = {
    enable = true;

    # The system-level `programs.niri` already installs the units and the
    # portal, so home-manager only provides the package here -- along with
    # xwayland-satellite, which the NixOS module deliberately omits
    # (enableXWayland = false) and which niri auto-spawns from PATH for emacs,
    # slack, zoom and chrome.
    systemd.enable = false;
    portalPackage = null;

    # settings/extraConfig are left empty on purpose. The module only claims
    # ~/.config/niri/config.kdl when they produce content, so leaving them
    # empty frees the path for the out-of-store symlink below and keeps niri's
    # config editable live. It also means `checkConfig` no longer validates
    # anything, since there is nothing generated to validate.
  };

  # Out-of-store symlink so niri config edits apply on save -- niri watches
  # this file and reloads itself. Same pattern the eww and leftwm configs used.
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/niri/config.kdl";

  # DMS's niri fragments, which its keybind editor, display panel and matugen
  # run all write into. Owned by DMS, tracked by us -- linked as a directory
  # rather than per-file for the same reason as the DankMaterialShell config:
  # DMS writes atomically, and a rename would replace a file-level symlink.
  xdg.configFile."niri/dms".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/niri/dms";

  # DMS's config directory, symlinked whole rather than per-file: it writes
  # settings.json with atomicWrites, so a file-level symlink would be replaced
  # by a regular file the first time its settings panel saved. Linking the
  # directory keeps the rename inside it, so DMS's GUI stays the owner of the
  # contents while the file itself is tracked.
  #
  # ~/.local/state/DankMaterialShell is deliberately NOT managed: it holds
  # pam/ at mode 700, app-usage stats and notepad contents.
  xdg.configFile."DankMaterialShell".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dank";

  # Cursor theme and size. Two layers are needed and both were missing after
  # stylix went: niri draws the cursor itself and scales it per output (that
  # block lives in niri/dms/cursor.kdl), while clients that draw their own read
  # XCURSOR_THEME/XCURSOR_SIZE, which this sets. Without a theme installed at
  # all, toolkits fall back independently and the cursor ends up a different
  # physical size on each differently-scaled monitor.
  #
  # stylix used size 20; 24 is the more widely shipped bitmap size, so themes
  # have exact art for it at 1x and 2x rather than scaling.
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
  };

  home.sessionVariables = {
    # DMS resolves the terminal as terminalOverride -> $TERMINAL -> "", and its
    # callers then fall back to hardcoded "xterm" (spotlight launching a
    # Terminal=true .desktop, and the session service) or "ghostty" (the
    # tmux/zellij mux). Neither is installed, and settings.json is GUI-owned
    # rather than declaratively generated -- it has no terminalOverride key at
    # all -- so without this those paths fail silently.
    TERMINAL = "alacritty";
  };

  xdg.configFile = {
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
}
