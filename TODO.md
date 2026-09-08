# `try-dms` follow-ups

The branch swaps leftwm + eww + stylix for niri + DankMaterialShell, and does so
**minimally on purpose**: roughly what DMS's own NixOS/home-manager docs
prescribe, plus the keyboard layout and a floor of keybinds. Everything else was
deliberately left out so the starting point is DMS's defaults rather than a
port of the old desktop. Add things back only once you actually miss them.

**This file must not survive the merge to `main`.**

## Delete dead configuration

- [x] `eww/`, `leftwm/`, `scripts/`, `home-manager/blugon/` and
      `home-manager/theme/` are gone, along with the generated `eww/colors.scss`
      and its .gitignore rule. README.md and AGENTS.md now describe the niri +
      DMS layout rather than the leftwm one.
- [x] Wallpapers moved out of the repo entirely, to
      `~/.local/share/wallpapers`. DMS manages them per monitor, keyed by
      monitor identity, and the files are large and derived.

## Left out of the minimal start

Most of this resolved itself rather than needing doing:

- [x] **GTK theming** is split. DMS owns the colours: `gtk.css` in both
      `gtk-3.0` and `gtk-4.0` imports the `dank-colors.css` its matugen run
      writes. home-manager owns the selection -- `settings.ini`, `.gtkrc-2.0`
      and the dconf interface keys -- because DMS never writes
      `gtk-theme-name`, and its palette uses libadwaita colour names that only
      adw-gtk3 reads. `gtk4.theme` stays null so home-manager does not take
      `gtk-4.0/gtk.css` away from DMS.
- [x] **Cursor theme** restored with `home.pointerCursor` (Bibata-Modern-Ice,
      24) when the cursor turned out to be a different size on every monitor.
- [x] **Qt theming** dropped rather than done. It was justified by pinentry-qt
      and yubioath-flutter; both are gone, and nothing Qt-facing is left.
- [x] **Font defaults** set in `nixos/base.nix`. Inter and Fira Code were
      already installed via the dms-greeter module, and the Noto families via
      enableDefaultPackages, so only the fontconfig preference was missing --
      generic sans-serif was still resolving to DejaVu.
- [x] **Alacritty opacity** back to 0.95.
Note, not a task: `services.displayManager.dms-greeter.logs.save` is off, and
deliberately so -- it writes a world-readable /tmp/dms-greeter.log. Turn it on
temporarily if the greeter ever fails, since without it a failure is just a
black screen.

## niri config still to wire up

`niri/config.kdl` is now DMS's shipped config and pulls in DMS's runtime
fragments from `~/.config/niri/dms/`. Deployed and live: `binds.kdl`,
`colors.kdl`, `layout.kdl`, `alttab.kdl`, `outputs.kdl`, `cursor.kdl`, plus
`windowrules.kdl` and `wpblur.kdl`, which upstream's include list omits. That
closed the old monitor-layout item (DMS's display GUI owns `outputs.kdl`, and
it matches what niri auto-detected) and the niri-borders-ignore-the-theme item
(`colors.kdl`).

- [x] ~~Two DMS bindings collide with things used here.~~ Accepted as they
      are, 2026-09-08. `Ctrl+Shift+R` (rename workspace, binds.kdl:147) takes
      hard-reload from Chrome and zen, and `Alt+Space` (spotlight bar,
      binds.kdl:12) shadows Doom's alternate leader `M-SPC`. Both are
      upstream's choices rather than ours; neither is worth moving.

      Correcting the fix this item proposed, in case it is ever wanted: a local
      `binds` block after the includes does NOT work. niri has no unbind --
      every bind needs an action, and an empty block, a bare key and a `none`
      action are all rejected. Overriding only changes what the key does; niri
      still grabs it, so the app never sees it either way.

      What does work is editing `niri/dms/binds.kdl`. It is DMS-generated but
      authoritative -- there are no keybinds in dank/settings.json, and
      `Mod+T { spawn "alacritty"; }` is already a hand-tuned entry surviving
      there. Free keys as of now: `Mod+Ctrl+N`, and for the spotlight bar
      `Mod+Slash`, `Mod+Ctrl+Space`, `Mod+Shift+Space`, `Mod+Semicolon`,
      `Mod+Apostrophe`. Prefer punctuation or space over letters, since letter
      binds resolve against the layout and land somewhere else under Colemak.
- [x] ~~Move the Colemak layout into DMS's Keyboard tab.~~ Done 2026-09-08.
      Settings -> Keyboard now holds layout `us`, variant `colemak`, options
      `caps:escape`; NiriService writes them as an xkb block into
      dms/input.kdl, and `niri msg keyboard-layouts` reports
      "English (Colemak)". The duplicate in niri/config.kdl is removed, which
      also puts that file's input block back to upstream apart from the two
      pointer settings.

      The hazard this item existed for is gone with it: xkb is a
      replace-wholesale field and the include lands last, so the copy in
      config.kdl was already being overridden rather than merged -- one visit
      to that tab would have taken layout, variant and caps:escape together.
      DMS owns the whole input node now, which is the arrangement that cannot
      silently diverge.
- [x] ~~Colemak scatters DMS's vim cluster.~~ Accepted as is, 2026-09-08.
      niri resolves latin binds against the configured layout, so `Mod+H/J/K/L`
      land on physical H/Y/N/U, `Mod+O` on `;`, and `Mod+U`/`Mod+I` on I/L.
      Nothing is unreachable -- arrows and `Mod+Tab` cover the important ones
      -- and remapping 134 binds to chase the labels is not worth it.

## Display profiles

Two profiles exist, keyed by make/model/serial rather than connector name:
"Laptop only" (eDP-1 at scale 1.5) and "Docked" (the four-output DPI-matched
layout). `displayNameMode` is set to "model" for that keying. Auto switching
is off -- `displayProfileAutoSelect` defaults false and is not overridden, and
`dms ipc call outputs status` reports `auto: off`.

Connector names are NOT stable: unplugging and replugging the externals
renumbered them DP-9/DP-12/DP-10 -> DP-11/DP-15/DP-13. Anything keyed on the
connector name breaks across a replug, which is why the profiles use
descriptions. The stable identities are:

    Dell Inc. DELL S2421HS C0BK7P3    left 24"
    Dell Inc. DELL S2722DGM DW8HZ83   middle 27"
    Dell Inc. DELL S2421HS 39BK7P3    right 24"
    BOE 0x0BCA Unknown                laptop

- [x] **What `displayProfileAutoSelect` actually does.** Read from
      DisplayConfigState.applyAutoConfig(); two earlier notes here got this
      wrong and are replaced.

      It is wired to hotplug through a 400ms debounce timer, and when a profile
      matches the connected set it applies it. When nothing matches it instead
      captures the current layout and saves it as a profile with an empty name
      -- which is where the unnamed duplicate in monitors.json came from. It was
      not the save flow, and deleting it by hand was always going to lose that
      race.

      It bails early on `manualActivation`, set for 2 seconds after any manual
      setProfile, and on `hasPendingChanges`. Repeated setProfile calls while
      debugging kept that guard set, which is the likeliest reason it appeared
      never to apply.

      A `displayProfileManager` plugin is now installed to handle switching, so
      this is no longer on the critical path.
- [x] ~~Pin the installed plugins declaratively.~~ The module option exists
      (`programs.dank-material-shell.plugins.<name>.src`, new in 1.6) but
      cannot be used here, and the inventory this item listed was already
      stale. Both established 2026-09-08.

      It cannot be used because the option writes
      `xdg.configFile."DankMaterialShell/plugins/<name>"`, and this config
      links the whole DMS config directory as one out-of-store symlink to
      `dank/`. home-manager follows that symlink and refuses to write through
      it -- building home-files with a plugin declared fails with
      `Error installing file '.config/DankMaterialShell/plugins/<name>' outside
      $HOME`. The directory symlink is not negotiable for the reason recorded
      in home.nix: DMS writes settings.json atomically, so a file-level symlink
      is replaced by a regular file on the first save.

      The inventory was wrong too. displayProfileManager and materialWeather
      are both gone. What is actually installed and used is one third-party
      plugin, dankDesktopWeather -- AvengeMedia/dms-plugins @ cb66135,
      subdirectory DankDesktopWeather, four files, 48K, MIT. There is also a
      dankAlbumWidget clone that nothing references, superseded by our
      albumPlayer fork.

      That plugin also carries an unrecorded local patch, in the untracked
      clone under `plugins/.repos/`, which `dms plugins update` would revert:
      hourlyForecast[0] is midnight rather than the current hour, so the
      forecast strip always started at 00:00. The patch slices from
      `(new Date()).getHours()` instead.

      Left for later, with three ways out: vendor it into `dank/plugins/` the
      way albumPlayer was vendored, so the patch becomes tracked; keep the
      clone and commit the diff as a .patch to reapply by hand; or upstream the
      fix and drop the patch once it lands.
- [x] ~~DMS and niri quantise scale differently, and it can overlap outputs.~~
      Checked while docked on 2026-09-08. There is no mismatch, and there was
      never going to be one.

      DMS 1.6 writes `scale 1.175` into outputs.kdl -- the monitors.json value
      verbatim, not the 1.171875 this item expected -- and `niri msg outputs`
      reports 1.175 applied. The two candidate scales could not have differed
      anyway: niri quantises to 1/120, 1.175 x 120 = 141 exactly, and
      1.171875 x 120 = 140.625 rounds to the same 141. Both land on 1.175.

      The slack bc0eae4 added is no longer needed, and closing it proved the
      old note's arithmetic right where mine was wrong. 2560 / 1.175 is
      2178.72, so the 27" at x=1920 really does end at 4098.72 -- the 2179 in
      the old note, not the 2178 that `niri msg outputs` prints, which is
      truncated for display. Setting the next output to x=4098 overlapped by a
      fraction of a pixel and niri silently relocated the 27" to x=6018,
      exactly the failure this item predicted. x=4099 is the first position
      that does not overlap.

      Applied layout now: DP-9 at 0, DP-12 the 27" at 1920, DP-10 at 4099, and
      eDP-1 below it at 4099,1080 on scale 2. The 12px guard band is gone and
      the remaining gap is 0.28px.
- [x] ~~Editing monitors.json by hand needs a DMS restart.~~ Wrong. Both
      settings.json and monitors.json are FileViews with `watchChanges: true`,
      and a direct test confirmed it: editing settings.json while DMS ran was
      picked up immediately, and a subsequent DMS-side save preserved the edit
      rather than overwriting it. The edits that appeared to be clobbered were
      a two-writer race with the settings GUI being used at the same time, not
      DMS ignoring the file. Editing by hand is fine; just do not do it while
      the corresponding settings panel is open.

## Trimming packages

DMS is a Quickshell frontend, not a self-contained package. Its derivation
wraps nothing but Qt paths, and it reaches system services over D-Bus and CLI
tools over PATH. So "DMS replaces X" holds where X was a *GUI* and not where X
is a service or a command.

Already dropped, safely: blueman and pwvucontrol (DMS reimplements both against
BlueZ and PipeWire in its control centre), plus the earlier sweep of dunst,
trayer, autorandr, picom, xclip, feh, slop and shotgun.

Must stay, despite looking like leftovers -- each was checked, and none is
declared by DMS's own Nix modules:

    (libnotify was removed: BatteryService.sendAlert only shells out to
     notify-send when the alert's notificationType is 1, and all three battery
     types are now 0, i.e. DMS's own ToastService. The only remaining caller is
     profile image errors in PortalService.qml. Note the difference: notify-send
     reaches the notification centre and persists, a toast does not.)
    upower      Quickshell.Services.UPower backs the whole battery UI across
                eight files.
    imv         DMS has no image viewer; it delegates via defaultApp imageViewer.
    (pinentry switched to gnome3; see below. yubioath-flutter dropped, since
     the YubiKey is used for GPG and SSH, which gpg-agent covers with
     hardware.gpgSmartcards.)

Procedure, not a task: before dropping anything else, check whether DMS shells
out to it (`rg 'execDetached'` over the QML) and whether it is a D-Bus service
DMS consumes. `dms doctor` lists the optional ones it knows about.

- [x] ~~Verify GPG signing.~~ Works. Six commits signed on 2026-09-08 through
      pinentry-gnome3, after priming the agent once.

      Two things learned in the process. The prompter is activatable on the
      session bus as org.gnome.keyring.SystemPrompter and PrivatePrompter,
      served from gcr-3.41.2's own servicedir -- so it survives
      gnome-keyring.enable = false, which is now recorded in base.nix. And the
      binary itself is not GTK: it links gcr-base and ncurses and only speaks
      D-Bus. gcr-prompter draws the dialog, and that is the GTK, wayland-native
      half.

      The failure mode to recognise: `gpg: signing failed: Timeout` after
      `PINENTRY_LAUNCHED` means the dialog went up and nobody typed into it,
      not that the prompter is missing.

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

- [x] ~~settings.json pins the desktop widgets to `eDP-1` by name.~~ True, and
      accepted -- README now states outright that this repo is one machine's
      config, not a template, so restoring onto different hardware is not a
      goal. There are six widgets now, not three, and all six are pinned.

      Worth recording the mechanism, since the stored data is misleading. Each
      pref is an object carrying both a name and a model,
      `{name: "eDP-1", model: "0x0BCA"}`, but DesktopWidgetLayer's
      shouldShowOnScreen only ever reads the name from an object pref:

          return prefs.some(p => {
              if (typeof p === "string")
                  return p === screenKey || p === modelData.name;
              return p?.name === modelData.name || p === screenKey;
          });

      `p === screenKey` compares an object against a string, so it is always
      false. The model is stored and never consulted. A *string* pref is the
      only form that matches on the display name, and so the only form that
      respects displayNameMode.

## Verify on real hardware

- [x] ~~voxtype under Wayland.~~ The part this doubted works. The daemon has
      been up for hours under niri, and the evdev grab is fine:
      `Opened keyboard: "/dev/input/event18"`, `Devices updated: 5 keyboard(s)
      active`. Nothing about the hotkey or the clipboard path is
      display-server specific, as expected.

- [ ] **voxtype has no OSD, and it is a packaging gap rather than a Wayland
      one.** The daemon logs `preferred frontend 'voxtype-osd-gtk4' not
      installed; using 'voxtype-osd-quickshell' instead`, then
      `could not find 'shell.qml'`, then gives up: `OSD child exited 3 times
      within 5s`. So dictation runs with no visual feedback.

      Both frontends are unavailable for different reasons. The package ships
      `voxtype-osd` and `voxtype-osd-quickshell` but no `voxtype-osd-gtk4`,
      which is the configured default (`osd.frontend = "gtk4"`). And the
      quickshell frontend needs QML assets that are not in the package either
      -- `share/voxtype/` holds only `default-config.toml`.

      Three ways out: set `osd.enabled = false` and rely on the
      `output.notification.*` options, which DMS already renders; point
      `osd.style` at a Quickshell package that provides the QML; or get the
      gtk4 frontend built in the voxtype flake. The first just stops the
      crash-loop; the daemon keeps working either way.
- [x] ~~Doom Emacs.~~ Done in `doom: load the theme DMS has been generating
      all along`. Note the one-liner suggested here would not have worked:
      matugen writes into `~/.config/emacs/themes/`, which Doom does not
      search, so the directory has to go on `custom-theme-load-path` first.
      `user-emacs-directory` is the wrong way to name it -- Doom reassigns that
      to the profile cache. Run `doom sync` to tangle it.
- [x] ~~Wallpaper.~~ Set. Confirmed by matugen regenerating
      `dank-emacs-theme.el` on 2026-09-08.

## Optional

Note, not a task: `services.geoclue2.enable = true` would let DMS night mode
take its schedule from your location rather than a manual latitude/longitude.
Left off deliberately -- it means location lookups leave the machine.
