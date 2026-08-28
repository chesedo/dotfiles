#!/usr/bin/env bash
# Cut one image into per-monitor crops so it spans the whole desktop, and hand
# them to DMS.
#
# DMS has no spanning mode: WallpaperBackground.qml is a Variants over
# Quickshell.screens, so every output draws the whole image independently. The
# way to fake it is per-monitor wallpapers over a pre-split source, which is
# what this does.
#
# Geometry is read live from `niri msg outputs` rather than hardcoded, because
# neither the layout nor the connector names are stable -- unplugging and
# replugging the externals has renumbered them (DP-9 -> DP-11 and so on), and
# the scales change with the display profile. Re-run this after docking, after
# changing a profile, or after picking a new wallpaper in DMS (Mod+Y), since
# that sets one image across all screens and undoes the span.
#
# Crops are applied with `setFor <connector>`, but DMS does not store them under
# that name: setMonitorWallpaper resolves the screen and keys the entry by
# SettingsData.getScreenDisplayName(), which with displayNameMode = "model" is
# the model plus an index for duplicates -- "DELL S2421HS-0", "DELL S2421HS-1".
# That index comes from getScreensSortedByPosition(), so it tracks physical
# order rather than serial or connector. For a spanned wallpaper that is the
# behaviour you want: the left-hand crop stays on the left-hand panel even if
# two identical monitors are swapped.
#
# Usage: wallpaper-span [SOURCE_IMAGE]
#   defaults to whatever DMS currently has as the base wallpaper.
set -euo pipefail

src="${1:-}"
if [ -z "$src" ]; then
    src=$(jq -r '.wallpaperPath // empty' \
        "${XDG_STATE_HOME:-$HOME/.local/state}/DankMaterialShell/session.json")
fi
[ -n "$src" ] && [ -f "$src" ] || { echo "no source image: ${src:-<unset>}" >&2; exit 1; }

out="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers/span"
mkdir -p "$out"

outputs=$(niri msg --json outputs)

# Bounding box of the whole desktop in logical pixels.
read -r bw bh < <(jq -r '[to_entries[].value.logical]
    | (map(.x + .width) | max) as $w
    | (map(.y + .height) | max) as $h
    | "\($w) \($h)"' <<<"$outputs")

echo "desktop bounding box: ${bw}x${bh} logical"

# Scale the source to cover that box, cropping rather than stretching.
canvas="$out/.canvas.png"
magick "$src" -resize "${bw}x${bh}^" -gravity center -extent "${bw}x${bh}" "$canvas"

# One crop per output: its logical rect out of the canvas, resized to the
# physical pixels of its current mode so the result is sharp on HiDPI panels.
while IFS=$'\t' read -r name lx ly lw lh pw ph; do
    dest="$out/$name.png"
    magick "$canvas" -crop "${lw}x${lh}+${lx}+${ly}" +repage -resize "${pw}x${ph}!" "$dest"
    printf '  %-8s logical %sx%s+%s+%s -> %sx%s physical\n' "$name" "$lw" "$lh" "$lx" "$ly" "$pw" "$ph"
    dms ipc call wallpaper setFor "$name" "$dest" >/dev/null
done < <(jq -r 'to_entries[] | .value
    | [.name, (.logical.x|floor), (.logical.y|floor),
       (.logical.width|floor), (.logical.height|floor),
       .modes[.current_mode].width, .modes[.current_mode].height]
    | @tsv' <<<"$outputs")

rm -f "$canvas"
echo "done; re-run after any layout or wallpaper change"
