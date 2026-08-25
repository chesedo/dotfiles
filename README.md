# 🏔️ Dotfiles - Alpine Slate Theme

> Modern, declarative NixOS configuration with a cohesive alpine-granite aesthetic

## ✨ Features

- **NixOS** with flakes for reproducible system configuration
- **LeftWM** tiling window manager with custom theming
- **EWW** widgets for system monitoring and app launching
- **Unified theming** across all applications from a single base16 file
- **Framework 13 AMD** optimized configuration

## 🚀 Quick Start

```bash
# Clone dotfiles
git clone <repo> ~/dotfiles
cd ~/dotfiles

# Setup system (run as root)
sudo nixos-rebuild switch --flake .

# Setup user environment
home-manager switch --flake .
```

## 🎨 Theme

The **Alpine Slate** color palette creates a deep, focused environment, keyed to
the wallpaper (alpine granite at dawn) and tuned cooler than the raw samples:
- **Background**: `#16181C` (deep neutral slate)
- **Foreground**: `#D6DAE0` (cool silver)
- **Accent**: `#9C7FA6` (muted mauve, cloud light)
- **Highlight**: `#5F87AE` (steel blue cliff shadows)

Defined once in `home-manager/theme/alpine-slate.nix`; most consumers get it
via Stylix, though a couple import it directly or need a hand-synced copy.
See [`leftwm/themes/current/README.md`](leftwm/themes/current/README.md) for how
to change it and which files are generated rather than edited.

## 🔧 Key Components

- **Window Manager**: LeftWM with custom theme and keybindings
- **Compositor**: Picom with blur effects and rounded corners
- **Terminal**: Alacritty with FiraCode Nerd Font
- **Widgets**: Custom EWW panels for productivity
- **Editor**: Doom Emacs with Rust/Nix/Python LSP support
- **Launcher**: Custom executable finder with caching

## 📱 Widgets

- System resources (CPU, RAM, Network)
- Battery status for all devices
- Music player integration
- Clipboard history manager
- Screenshot tool with preview
- Notification center

## ⚡ Productivity

- **Per-project environments** with nix-shell
- **Vim-style navigation** everywhere
- **Multi-monitor support** with autorandr
- **GPG/YubiKey integration** for security
- **Org-roam** for knowledge management

## 📖 Structure

```
├── nixos/           # System configuration
├── home-manager/    # User environment  
├── leftwm/          # Window manager setup
├── eww/             # Widget configuration
├── .doom.d/         # Emacs configuration
└── scripts/         # Utility scripts
```

---

*Optimized for Framework 13 AMD • Built with NixOS flakes • Themed for productivity*
