{ pkgs, config, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim  # or some other editor, e.g. nano or neovim

    git
    fd
    ripgrep
    emacs

    gzip
    zsh

    # Some common stuff that people expect to have
    #diffutils
    #findutils
    #utillinux
    #tzdata
    #hostname
    #man
    #gnugrep
    #gnupg
    #gnused
    #gnutar
    #bzip2
    #gzip
    #xz
    #zip
    #unzip
  ];
  environment.sessionVariables = {
    EDITOR = "emacs";
  };

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "21.11";

  # After installing home-manager channel like
  #   nix-channel --add https://github.com/rycee/home-manager/archive/release-21.11.tar.gz home-manager
  #   nix-channel --update
  # you can configure home-manager in here like
  home-manager.config =
    { pkgs, lib, ... }:
    {
      # Read the changelog before changing this value
      home.stateVersion = "21.11";
  
      # Use the same overlays as the system packages
      nixpkgs = { inherit (config.nixpkgs) overlays; };
  
      # insert home-manager config
      home.packages = with pkgs; [
        jq
      ];
      programs = {
        # Let Home Manager install and manage itself.
        home-manager.enable = true;

        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        git = {
          enable = true;
          userName  = "chesedo";
          userEmail = "pieter@chesedo.me";
          extraConfig = {
            core.askPass = "";
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
        };
      };

      home.file = {
        ".p10k.zsh".source = ~/git/dotfiles/.p10k.zsh;
        ".doom.d" = {
          source = ~/git/dotfiles/.doom.d;
          onChange = "~/.emacs.d/bin/doom sync";
        };
      };
    };

  # If you want the same pkgs instance to be used for nix-on-droid and home-manager
  home-manager.useGlobalPkgs = true;

  user.shell = "${pkgs.zsh}/bin/zsh";
}

# vim: ft=nix
