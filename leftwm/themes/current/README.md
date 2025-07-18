# 🌅 Sunset Cave - LeftWM Theme

> Modern LeftWM theme with EWW widgets and sunset-inspired colors

## 🎨 Theme

**Color Palette:**
- Background: `#1A1A1D` | Foreground: `#E6DDD1` 
- Accent: `#E8846C` | Highlight: `#FFB4A2`

**Window Management:**
- No borders (border_width: 0)
- 32px margins for clean spacing
- Picom compositor with blur and rounded corners

## 🔧 Components

**EWW Widgets:** Information panel on monitor 1 with system stats, battery, time, music, and notifications

**Interactive Tools:**
- `Mod+P`: App launcher with executable search
- `Mod+Ctrl+C`: Clipboard history manager  
- `Print`: Screenshot tool with preview

**Services:** Picom, Blugon, Trayer (monitor 2), EWW widgets, Emacs daemon

## 📁 Files

- `up/down`: Theme start/stop scripts
- `theme.ron`: LeftWM window configuration  
- `picom.conf`: Compositor settings
- EWW config symlinked from `~/dotfiles/eww/`

## 💡 Setup

Designed for NixOS with 3-monitor Framework 13 setup. EWW widgets provide system monitoring and productivity tools with unified theming across all components.
