# `try-dms` follow-ups

The branch swaps leftwm + eww + stylix for niri + DankMaterialShell, and does so
**minimally on purpose**: roughly what DMS's own NixOS/home-manager docs
prescribe, plus the keyboard layout and a floor of keybinds. Everything else was
deliberately left out so the starting point is DMS's defaults rather than a
port of the old desktop. Add things back only once you actually miss them.

**This file must not survive the merge to `main`.**

## Delete dead configuration

- [ ] `eww/` — every widget it defined is a DMS built-in now. Nothing in the
      nix tree references it.
- [ ] `leftwm/` — including `leftwm/themes/`. Move
      `leftwm/themes/current/background.jpg` somewhere neutral (e.g.
      `wallpapers/`) first if you still want that image; nothing references it
      any more since stylix was removed, and DMS owns the wallpaper now.
- [ ] `scripts/` — all six are dead: `screenshot.sh`, `clipboard.sh`,
      `filter-executables.sh`, `update-executables-cache.sh`,
      `dunst-update-eww.sh`, `clear-app-notifications.sh`. DMS replaces each
      one (`dms screenshot`, clipboard history, spotlight, notification centre).
- [ ] `home-manager/theme/alpine-slate.nix` and `home-manager/blugon/` — only
      stylix and blugon read these.
- [ ] `README.md` still advertises LeftWM, EWW, Picom and autorandr.

## Left out of the minimal start — add back if missed

- [ ] **Monitor layout.** The old `autorandr` "home" profile (laptop + three
      Dells) is gone; niri will auto-place outputs left to right in whatever
      order it finds them. When you write `output` blocks, mind the arithmetic:
      niri quantises scale to 1/120 steps, and no representable step divides
      the 27"'s 2560 into the 2176 logical pixels xrandr's `scale 0.85` gave —
      1.175 is nearest, yielding about 2178. niri does **not** error on
      overlapping outputs; it logs `overlaps an existing output … falling back
      to automatic placement` and silently rearranges the desktop. Get the real
      numbers from `niri msg outputs` first, and leave a few logical pixels of
      slack. The two DELL S2421HS panels differ only by serial (`C0BK7P3` and
      `39BK7P3`).
- [ ] **The rest of the keybinds.** Only five are bound: hotkey overlay,
      terminal, close, quit, spotlight. The leftwm set that has no equivalent
      yet: workspaces 1-9 and move-to-workspace (`focus-workspace` /
      `move-column-to-workspace`), `Mod+j/k` focus and `Mod+Shift+j/k` move,
      column width on `Mod+minus`/`Mod+equal`, fullscreen on `Mod+f`, and the
      DMS ones — `dms ipc notifications|clipboard|processlist|settings|
      powermenu|night|lock`, `dms screenshot` on Print, plus the media and
      brightness keys (`dms ipc audio increment|decrement|mute|micmute`,
      `dms ipc brightness increment|decrement 5 ""`).
- [ ] **GTK theming.** DMS's matugen writes `~/.config/gtk-3.0/dank-colors.css`
      and the gtk-4.0 equivalent, but nothing imports them, so GTK apps ignore
      the shell theme. Either add `gtk3/gtk4.extraCss` with an `@import`, or let
      DMS's own "apply GTK colors" action own `gtk.css` — pick one owner, since
      home-manager writes that file as a read-only store symlink and DMS
      inspects the symlink target to decide whether its theming is live.
- [ ] **Qt theming.** `QT_QPA_PLATFORMTHEME = "qt6ct"` plus the
      `qt6Packages.qt6ct` package; DMS's matugen already targets
      `qt6ct/colors/matugen.conf`. Relevant to `pinentry-qt` and
      `yubioath-flutter`.
- [ ] **Icon and cursor themes.** stylix used to set Papirus-Dark and
      Bibata-Modern-Ice at size 20 (`gtk.iconTheme`, `home.pointerCursor`).
- [ ] **Font defaults.** stylix set FiraCode Nerd Font everywhere; without it
      fontconfig falls back to DejaVu for sans/serif. `fonts.fontconfig.
      defaultFonts` in `nixos/base.nix` is where that would go, along with
      `inter` and `fira-code` if `dms doctor` keeps complaining (the greeter
      module already contributes both, plus `material-symbols`).
- [ ] **Alacritty opacity** was 0.95 under stylix.
- [ ] **`services.displayManager.dms-greeter.logs.save`** — turn on temporarily
      if the greeter ever fails; without it a failure is just a black screen.
      Note it defaults to a world-readable `/tmp/dms-greeter.log`.

## Let DMS own more of the niri config

niri supports `include optional=true "path"`, verified against niri 26.04: a
missing target is a warning and the config still validates, where a plain
`include` is a hard error. So these can be added without breaking
home-manager's build-time `checkConfig`, even though the files never exist in
the build sandbox. Includes resolve relative to the symlink's directory, so
they work despite `config.kdl` being a store symlink.

- [ ] `include optional=true "dms/colors.kdl"` — DMS's matugen already writes
      this file (`matugen/configs/niri.toml`) and nothing reads it, so niri's
      own borders and focus ring ignore the wallpaper theme.
- [ ] `include optional=true "dms/binds.kdl"` to let DMS's keybind editor own
      binds. Put the local `binds` block *after* the include so it wins. DMS
      only writes that file once you edit a bind in its GUI.
- [ ] `include optional=true "dms/outputs.kdl"` would hand the monitor layout to
      DMS's display GUI, sidestepping the scale arithmetic above entirely.
- [ ] Do not import `dms.homeModules.niri`. It is a separate opt-in flake output
      written against niri-flake's `programs.niri.settings`, and it `mkForce`s
      `xdg.configFile.niri-config`, which collides with the `niri/config.kdl`
      entry `wayland.windowManager.niri` already owns. Read it for its include
      list and bind set, don't import it.

## Verify on real hardware

- [ ] **voxtype.** It grabs `RIGHTCTRL` through evdev and pastes via the
      clipboard, both of which should be display-server agnostic, but this has
      only ever run under X11 here.
- [ ] **Doom Emacs.** DMS matugen writes
      `~/.config/emacs/themes/dank-emacs-theme.el`; `.doom.d/config.el` needs a
      `(load-theme 'dank-emacs t)` to pick it up, replacing whatever stylix set.
- [ ] **Wallpaper.** Set it once in DMS's settings — that is what drives every
      generated palette, and `dms-greeter.configHome` copies the result to the
      login screen.

## Optional

- [ ] `services.geoclue2.enable = true` if you want DMS night mode to pick its
      schedule from your location rather than a manual latitude/longitude. Off
      deliberately — it means location lookups leave the machine.

## On `main`, before switching away

- [ ] Add `system.nixos.tags = [ "leftwm" ];` and rebuild, so the leftwm
      generation is labelled in the boot menu. This branch already tags itself
      `dms`.
