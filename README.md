# 🌅 Dotfiles - Sunset Cave Theme

> Modern, declarative NixOS configuration with a cohesive sunset-inspired aesthetic

## ✨ Features

- **NixOS** with flakes for reproducible system configuration
- **LeftWM** tiling window manager with custom theming
- **EWW** widgets for system monitoring and app launching
- **Doom Emacs** with custom sunset-cave theme and LSP setup
- **Unified theming** across all applications
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

The **Sunset Cave** color palette creates a warm, productive environment:
- **Background**: `#1A1A1D` (dark cave)
- **Foreground**: `#E6DDD1` (warm cream) 
- **Accent**: `#E8846C` (sunset orange)
- **Highlight**: `#FFB4A2` (coral)

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
