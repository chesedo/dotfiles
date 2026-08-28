# 🏔️ Dotfiles

> Modern, declarative NixOS configuration for a Framework 13 AMD

## ✨ Features

- **NixOS** with flakes for reproducible system configuration
- **niri** scrollable-tiling Wayland compositor
- **DankMaterialShell** for the bar, launcher, notifications, control centre and
  lock screen, themed from the wallpaper
- **Framework 13 AMD** optimized configuration

## 🚀 Quick Start

```bash
# Clone dotfiles
git clone <repo> ~/dotfiles
cd ~/dotfiles

# Setup system (run as root)
sudo nixos-rebuild switch --flake .

# Setup user environment. --impure is required: home.nix reads secrets.nix
# through builtins.getEnv "HOME"
home-manager switch --flake .#chesedo --impure
```

## 🎨 Theme

Colours are generated from the wallpaper by DMS's matugen run, which writes
themes for GTK, Qt, alacritty, Emacs, Zen and niri itself. There is no central
palette file: set the wallpaper and everything follows. Wallpapers themselves
live outside the repo, in `~/.local/share/wallpapers`, since they are large and
DMS manages them per monitor.

The niri fragments DMS generates live in `niri/dms/` and are tracked, so a theme
change shows up as a diff.

## 🔧 Key Components

- **Compositor**: niri, configured in `niri/config.kdl` — DMS's shipped config
  with local deviations marked inline
- **Shell**: DankMaterialShell (bar, launcher, notifications, control centre,
  clipboard, screenshots, lock screen)
- **Terminal**: Alacritty with FiraCode Nerd Font
- **Editor**: Doom Emacs with Rust/Nix/Python LSP support
- **Files**: Nautilus, which also backs the desktop portal's file chooser

## 🖥️ Displays

Monitor layouts are DMS display profiles, stored in `dank/monitors.json` and
keyed by monitor identity rather than connector name, since connectors renumber
across a replug. A custom plugin in `dank/plugins/profileSwitcher/` switches
between them and swaps which bar is enabled and whether desktop widgets show,
so the laptop screen behaves differently docked and undocked.

## ⚡ Productivity

- **Per-project environments** with nix-shell and direnv
- **Vim-style navigation** everywhere
- **GPG/YubiKey integration** for security
- **Org-roam** for knowledge management

## 📖 Structure

```
├── nixos/           # System configuration
├── home-manager/    # User environment
├── niri/            # Compositor config, symlinked live into ~/.config/niri
├── dank/            # DankMaterialShell config, symlinked live
└── .doom.d/         # Emacs configuration
```

Both `niri/` and `dank/` are out-of-store symlinks, so edits there take effect
without a rebuild.

---

*Optimized for Framework 13 AMD • Built with NixOS flakes*
