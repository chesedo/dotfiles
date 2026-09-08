# 🏔️ Dotfiles

> Modern, declarative NixOS configuration for a Framework 13 AMD

## ✨ Features

- **NixOS** with flakes for reproducible system configuration
- **niri** scrollable-tiling Wayland compositor
- **DankMaterialShell** for the bar, launcher, notifications, control centre and
  lock screen, themed from the wallpaper
- **Framework 13 AMD** optimized configuration

## 🚀 Quick Start

This is one machine's config rather than a template, and it assumes three things
that will not hold elsewhere. `nixos/base.nix` declares `chesedo` as the only
user under `mutableUsers = false`, and `home.nix` hardcodes that home directory.
`hardware-configuration-framework-13.nix` is tracked here and imported directly,
so the installer's own scan is never read -- it mounts by the labels `nixos`,
`BOOT`, `Extra` and `swap`. Nothing checks those while evaluating or building, so
on other disks the breakage surfaces at boot. And the clone has to sit at `~/dotfiles`, which
`home.nix` reaches by absolute path for secrets and for its out-of-store
symlinks.

```bash
# A fresh install has no git yet, hence the nix-shell.
nix-shell -p git --run 'git clone <repo> ~/dotfiles'
cd ~/dotfiles
./setup.sh
```

`setup.sh` runs both layers in order. Unless `home-manager/secrets.nix` is
already in place, the first run stops after the system layer to have you fill it
in -- it is gitignored, and holds `jiraApiToken` and `googleCalendars`. Run the
script again once that is done.

Log out and back in at the end -- niri and the DMS greeter only take over from
the next session.

The two layers by hand, if you would rather. `home-manager/secrets.nix` has to
exist first, or the user layer fails on a missing path:

```bash
# The configuration is named rather than derived from the hostname, which on a
# fresh install is still the installer default.
sudo nixos-rebuild switch --flake .#nixos-framework-13

# --impure is required: home.nix reads secrets.nix through builtins.getEnv "HOME"
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
