# 🏔️ Alpine Slate - LeftWM Theme

> Modern LeftWM theme with EWW widgets and alpine granite colors

## 🎨 Theme

**Color Palette:**
- Background: `#16181C` | Foreground: `#D6DAE0`
- Accent: `#9C7FA6` | Highlight: `#5F87AE`

**Window Management:**
- No borders (border_width: 0)
- 32px margins for clean spacing
- Picom compositor with blur and rounded corners

## 🔧 Components

**EWW Widgets:** the `information` window — tags, voxtype, systray, clock and
calendar, weather, CPU/RAM/network, batteries, and music — on the laptop panel
(eDP-1). It declares `:monitor 0` — a GDK index, which in practice resolves to
eDP-1 rather than to DP-9 at `+0+0` (verified by screenshotting eDP-1's
rectangle). GDK's ordering is not something to rely on: if it ever lands on the
wrong screen, eww also accepts an output name, `:monitor "eDP-1"`.

`notification-panel` is a separate window and declares `:monitor 1`, so
notifications appear on a different screen.

**Interactive Tools** (from `leftwm/config.ron`):
- `Mod+P`: App launcher with executable search
- `Mod+C`: Clipboard history manager
- `Mod+N`: Toggle the notification panel
- `Print`: Screenshot tool with preview

**Services started by `up`:** Picom, Blugon, feh (wallpaper), LeftWM theme, `eww open information`

> ⚠️ `down` still runs `feh --bg-scale $SCRIPTPATH/down.jpg`, but no `down.jpg`
> exists here. `up` runs the previous theme's `down` first (via
> `/tmp/leftwm-theme-down`), and leftwm re-runs `up` on SoftReload
> (`Mod+Shift+R`), so this fails on load and reload too — not just unload. It
> also `pkill`s trayer, which `up` never starts.

## 📁 Files

- `up/down`: Theme start/stop scripts
- `theme.ron`: LeftWM window configuration
- `picom.conf`: Compositor settings
- `background.jpg`: Wallpaper. Referenced by `stylix.image`, but no enabled
  Stylix target actually uses it (`targets.feh` is off), which is why the apply
  steps below need their own `feh` call. Touching it does force a rebuild.
- (EWW config lives in `~/dotfiles/eww/`, symlinked to `~/.config/eww` by
  home-manager — not a file in this directory)

## 🔄 Updating colors

Colours flow from **one** base16 file through Stylix — one source of truth, plus
three hand-synced copies that Nix cannot reach (see below):

```
home-manager/theme/alpine-slate.nix     ← single source of truth
```

Everything downstream is derived:

| Consumer | How it gets colours |
|---|---|
| Terminal, GTK, and other Stylix targets | `stylix.base16Scheme` in `home-manager/home.nix` |
| `eww/colors.scss` | **generated** by `home.activation.generateEwwColors` in `home-manager/home.nix` |
| LightDM mini greeter | `nixos/base.nix` imports the same file |
| `theme.ron` (this dir) | ⚠️ **manual copy** — see below |

Three things that will catch you out:

1. **Never edit `eww/colors.scss`** — it is regenerated on every activation and
   your changes vanish. Change `alpine-slate.nix` instead.
2. **`theme.ron` must be synced by hand.** LeftWM reads it directly and the
   `leftwm/` directory is an out-of-store symlink, so Nix cannot template it.
   Copy `base01` → `default_border_color`, `base0E` → `floating_border_color`,
   `base0D` → `focused_border_color`.

   Note these three are **currently inert**: `border_width: 0` means leftwm
   draws no borders at all. Keep them in sync so the theme is correct if you
   ever raise the width, but changing them today changes nothing on screen.
3. **Both READMEs quote the palette as literal hex** — the "Color Palette"
   block at the top of this file, and the Theme section of the root
   `README.md`. Nothing regenerates them, so they silently go stale. Update
   base00 / base05 / base0E / base0D in both when you change the scheme.

Apply with:

```bash
home-manager switch --flake ~/dotfiles        # Stylix targets + eww/colors.scss
sudo nixos-rebuild switch --flake ~/dotfiles  # greeter only
eww reload                                    # pick up regenerated scss

# theme.ron and background.jpg are NOT applied by the above -- leftwm reads
# them directly, so reload the theme yourself (or Mod+Shift+R):
leftwm-command "LoadTheme $HOME/.config/leftwm/themes/current/theme.ron"
feh --bg-scale --no-xinerama ~/dotfiles/leftwm/themes/current/background.jpg
```

Already-running Stylix consumers (terminals, GTK apps) keep the old palette
until they restart — the config on disk is rewritten, but live processes do not
reread it.

### Renaming the scheme

The filename is hardcoded in six places — miss one and you get a silent stale
reference. Grep for the **old** name from the repo root. `--hidden` is the flag
that matters: all six sites are tracked, non-ignored files, but one of them is
`.gitignore`, which `rg` skips by default:

```bash
rg -i --hidden --glob '!.git' 'alpine-dusk|alpine dusk' ~/dotfiles   # substitute what you renamed FROM
```

| file | what it is |
|---|---|
| `home-manager/home.nix` | `base16Scheme` import (functional) |
| `nixos/base.nix` | greeter import (functional) |
| `.gitignore` | comment above the `eww/colors.scss` entry |
| `home-manager/home.nix` (generator) | header written into the generated scss |
| `eww/eww.scss` | header comment |
| `leftwm/themes/current/theme.ron` | comment |

Plus the `scheme = "Alpine Slate";` string inside the file, the filename
itself, and prose in this file and the root `README.md`. The table lists only
the places that *reference* the file by name.

`eww/colors.scss` is gitignored so `rg` skips it anyway, and it is regenerated
on the next `home-manager switch` — never edit it by hand.

## 🖼️ Updating the wallpaper

`background.jpg` is **not** a single scenic image — it is a composite sized to
the exact X screen, so one continuous scene spans the three external monitors
while the laptop panel continues it downward from DP-10, which it sits beneath.

Current layout (`xrandr`):

```
Screen 0: current 6352 x 2584          ← framebuffer, larger than the outputs
DP-9    1920x1080  +0    +0
DP-12   2176x1224  +1920 +0
DP-10   1920x1080  +4096 +0
eDP-1   1128x752   +4096 +1080   ← below DP-10, not in the row
```

The four outputs only span 6016×1832, but the framebuffer is sized for eDP-1's
*unscaled* 2256×1504 panel at its +4096+1080 origin, giving 6352×2584 — so
~336px of width and ~752px of height belong to no output. The composite is built
at the full framebuffer size (feh paints the whole root pixmap).

The only black areas are the right strip (`x ≥ 6016`) and the bottom band
(`y ≥ 1840`). Everywhere the 6016×1840 source reaches carries image, including
large areas no output displays — below DP-9 and DP-12, beside eDP-1, and the
8-row overhang at `y = 1832…1839`. Harmless, but don't expect a regenerated
composite to look black there.

The source image is **6016×1840** and is pasted at `(0,0)`. Because eDP-1's
rectangle falls inside that, its content is continuous with DP-10 by
construction — no separate laptop image, no alignment step. The eDP rectangle
is then darkened to ~62% so the EWW panels stay legible; the hard edge at
`y=1080` is invisible because it falls across a physical bezel gap.

`up` sets it with `feh --bg-scale --no-xinerama`. That does not distort **only
because the composite is exactly screen-sized** — if you change resolutions or
rearrange monitors, regenerate at the new size rather than letting feh stretch.

⚠️ This holds for the docked `home` autorandr profile only. The `default`
profile is eDP-1 alone, `mode 2256x1504` at `scale 0.5` — so the framebuffer
becomes **2256×1504** (viewport 1128×752), not 1128×752.

Nothing repaints the wallpaper on a profile switch: `autorandr`'s only
`postswitch` hook is `log-profile`. So undocking mid-session just leaves the old
root pixmap in a resized framebuffer.

The real breakage appears the next time `up` runs (session start, or
`Mod+Shift+R`): `--bg-scale` stretches the composite over the 2256×1504
framebuffer, but only the top-left 1128×752 is scanned out — so you see roughly
composite region (0,0)–(3176,1292), i.e. DP-9's scene plus about 58% of DP-12,
squeezed ~1.64× horizontally. The darkened eDP rect is entirely off-screen.
Losing ~75% of the image matters more than the aspect squeeze; a separate
laptop-only wallpaper is the real fix.

Generation scripts live on the GPU box (`ssh WSL`, `~/imggen/`) — outside this
repo, so the exact invocations are not version-controlled here. Sketch of the
three stages (see the comments in those scripts for the full arguments):

```bash
# 1. wide guide, 2. whole-image img2img @0.90, 3. three grid passes 0.50→0.66
~/imggen/imagegen.sh --model sdxl-base --size 6016x1840 ... --out /out/guide.png
SCRIPT=refine.py  ~/imggen/imagegen.sh --passes 1 --tile 6016 --strength 0.90 ...
SCRIPT=refine.py  ~/imggen/imagegen.sh --passes 3 --strength 0.50 --decay 1.15 ...
```

Then composite to screen size, darken the eDP rect, and write JPEG (quality 92).
Stylix re-derives nothing from the image — the palette is hand-set in
`alpine-slate.nix` — so if the new wallpaper shifts hue, update that too.

## 💡 Setup

Designed for NixOS with a 3-monitor + laptop Framework 13 setup. EWW widgets
provide system monitoring and productivity tools with unified theming across all
components.
