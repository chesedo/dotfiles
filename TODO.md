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
`colors.kdl`, `layout.kdl`, `alttab.kdl`, `outputs.kdl`, `cursor.kdl`, plus
`windowrules.kdl` and `wpblur.kdl`, which upstream's include list omits. That
closed the old monitor-layout item (DMS's display GUI owns `outputs.kdl`, and
it matches what niri auto-detected) and the niri-borders-ignore-the-theme item
(`colors.kdl`).

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

## Display profiles

Two profiles exist, keyed by make/model/serial rather than connector name:
"Laptop only" (eDP-1 at scale 1.5) and "Docked" (the four-output DPI-matched
layout). `displayNameMode` is set to "model" for that keying, and auto
switching is on.

Connector names are NOT stable: unplugging and replugging the externals
renumbered them DP-9/DP-12/DP-10 -> DP-11/DP-15/DP-13. Anything keyed on the
connector name breaks across a replug, which is why the profiles use
descriptions. The stable identities are:

    Dell Inc. DELL S2421HS C0BK7P3    left 24"
    Dell Inc. DELL S2722DGM DW8HZ83   middle 27"
    Dell Inc. DELL S2421HS 39BK7P3    right 24"
    BOE 0x0BCA Unknown                laptop

- [ ] **Verify auto switching actually fires on the next unplug.** Both
      profiles are keyed by description and `matched: Docked` is reported, but
      the switch itself has not been observed yet.
- [ ] DMS keeps re-adding an unnamed duplicate of the Docked profile to
      monitors.json. findMatchingProfile skips profiles with an empty name so
      it is inert, but it comes back after a restart even once removed, so
      something in the save path writes it. Worth reporting upstream.
- [ ] Editing monitors.json by hand does not take effect while DMS is running:
      it applies profiles from an in-memory copy and will write the stale
      values back out. `systemctl --user restart dms.service` makes it re-read.
      Prefer the GUI.

## DMS config

`~/.config/DankMaterialShell` is symlinked to `dank/`, so `settings.json` is
tracked while DMS's settings GUI stays the owner of the contents. The
*directory* is linked rather than individual files because DMS writes with
`atomicWrites` (write-temp-then-rename), which would replace a file-level
symlink with a regular file on the first save. `~/.local/state/DankMaterialShell`
is deliberately left unmanaged -- it holds `pam/` at mode 700, app-usage stats
and notepad contents.

- [ ] **Revisit why `zen.css` and `plugins/` are gitignored** (`dank/.gitignore`).
      Both were excluded on first pass without much thought; decide properly.
      - `zen.css` looks purely derived -- its header says "DMS Matugen Zen
        Browser Theme" and it is regenerated on every theme change, so tracking
        it would be churn with no recovery value. Confirm nothing hand-edited
        ever lands in it.
      - `plugins/` is 3.7M and currently holds `materialWeather` and
        `dankDesktopWeather`, **each containing its own `.git`**. Committing
        them as-is would mean nested repos, which git will not track properly.
        The right answer is probably the Nix module's
        `programs.dank-material-shell.plugins.<name>.src`, which takes a
        `fetchFromGitHub` or path and installs declaratively -- that would make
        plugins reproducible without vendoring their trees. DMS's docs also
        mention a `plugins.lock.json` for reproducibility; no such file exists
        here, so work out what produces it and whether it belongs in git
        instead.
      - The `.gitignore` is now an allowlist (`*` + `!settings.json`) rather
        than a denylist, so files DMS creates later -- `plugin_settings.json`,
        which can hold plugin API keys, `monitors.json`, which carries output
        serials, and `themes/<id>/theme.json` -- cannot silently start being
        tracked. Revisit whether any of those *should* be.

- [ ] `settings.json` pins all three desktop widgets to output `eDP-1` by name
      (`desktopWidgetInstances[*].displayPreferences`), and DMS matches outputs
      strictly by name, so on a machine whose panel is not `eDP-1` the clock,
      system monitor and weather widgets silently do not render. Only affects
      restoring onto different hardware; the global `screenPreferences` keys are
      all `["all"]` and fine.
- [ ] Until this branch reaches `main`, `git checkout main` deletes
      `dank/settings.json` -- which *is* the live `~/.config/DankMaterialShell/
      settings.json`. DMS holds settings in memory and rewrites the file on the
      next change, so expect either a silent resurrection or, if DMS restarts
      first, a reset to defaults. Recoverable from git, but it happens without
      warning.
- [ ] Script the wallpaper span so it is reproducible rather than a one-off:
      crop the source to each output's logical rect within the desktop bounding
      box, resize to physical pixels, then `dms ipc call wallpaper setFor
      <output> <path>`. Needs redoing whenever the monitor layout changes or
      DMS's wallpaper browser (`Mod+Y`) sets a single image across all screens.
      Note the per-monitor paths live in `session.json`, i.e. in the unmanaged
      state directory, so they are not tracked.

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
