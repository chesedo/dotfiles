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

## niri config still to wire up

`niri/config.kdl` is now DMS's shipped config and pulls in DMS's runtime
fragments from `~/.config/niri/dms/`. Deployed and live: `binds.kdl`,
`colors.kdl`, `layout.kdl`, `alttab.kdl`, `outputs.kdl`, `cursor.kdl`. That
closed the old monitor-layout item (DMS's display GUI owns `outputs.kdl`, and
it matches what niri auto-detected) and the niri-borders-ignore-the-theme item
(`colors.kdl`).

- [ ] `windowrules.kdl` and `wpblur.kdl` are written by DMS but are not in the
      include list upstream ships, so they sit inert. Decide whether to add
      `include optional=true` lines for them. `Mod+Shift+W` (create window
      rule) is a no-op until `windowrules.kdl` is included.
- [ ] Two DMS bindings collide with things used here, both inherited from
      upstream rather than chosen: `Ctrl+Shift+R` (rename workspace) is a
      modifier-less global grab that eats hard-reload in Chrome and zen, and
      `Alt+Space` (spotlight bar) shadows Doom's alternate leader
      (`doom-leader-alt-key`, default `M-SPC`). Override either by adding a
      local `binds` block after the includes -- later definitions win across an
      include boundary, verified against niri 26.04.
- [ ] Colemak scatters DMS's vim cluster, since niri resolves latin binds
      against the first configured layout: `Mod+H/J/K/L` land on physical
      H/Y/N/U, `Mod+O` on `;`, `Mod+U`/`Mod+I` on I/L. Nothing is unreachable
      (arrows and `Mod+Tab` duplicate the important ones) but it may be worth
      remapping.

## Bring the DMS config under management

DMS writes `settings.json` and `session.json` with `atomicWrites: true`, i.e.
write-temp-then-rename, which **replaces a file symlink with a regular file**.
So the per-file `mkOutOfStoreSymlink` pattern used for niri does not work here
-- it would survive exactly until DMS's first save. Symlinking the *directory*
does work, because the rename happens inside it.

- [ ] Link `~/.config/DankMaterialShell` -> `dotfiles/dank/`, gitignoring
      `zen.css` (matugen-generated) and `plugins/` (vendored).
- [ ] Leave `~/.local/state/DankMaterialShell` unmanaged: it holds `pam/` at
      mode 700, app-usage stats and notepad contents, none of which belong in
      a dotfiles repo. Note this means the per-monitor wallpaper paths, which
      live in `session.json`, stay untracked.
- [ ] Script the wallpaper span so it is reproducible rather than a one-off:
      crop the source to each output's logical rect within the desktop bounding
      box, resize to physical pixels, then `dms ipc call wallpaper setFor
      <output> <path>`. Needs redoing whenever the monitor layout changes or
      DMS's wallpaper browser (`Mod+Y`) sets a single image across all screens.

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
