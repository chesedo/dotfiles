# Wallpapers

One image per monitor, set through DMS (Settings -> Wallpaper, per-monitor) or
`dms ipc call wallpaper setFor <connector> <path>`.

DMS has no spanning mode: `WallpaperBackground.qml` is a `Variants` over
`Quickshell.screens`, so each output draws its own image independently. Four
separate images is the whole mechanism -- there is nothing to generate.

## Sizes

Make each at its monitor's physical resolution:

| Monitor            | DMS key          | Size      |
|--------------------|------------------|-----------|
| Left 24" C0BK7P3   | `DELL S2421HS-0` | 1920x1080 |
| Middle 27" DW8HZ83 | `DELL S2722DGM`  | 2560x1440 |
| Right 24" 39BK7P3  | `DELL S2421HS-1` | 1920x1080 |
| Laptop             | `0x0BCA`         | 2256x1504 |

To make them read as one continuous picture, the desktop is 6030x1832
*logical*; cut these rects from a canvas that size, then upscale each to the
physical size above. The 27" and laptop rects are smaller than their physical
resolution because they run at scale 1.175 and 2.0.

    left 24"   1920x1080 at (0,0)
    27"        2178x1225 at (1920,0)
    right 24"  1920x1080 at (4110,0)
    laptop     1128x752  at (4110,1080)

## Keying

Assignments are stored in `~/.local/state/DankMaterialShell/session.json` under
`monitorWallpapers`, keyed by `getScreenDisplayName()` -- the model, plus an
index for duplicate models. That index comes from `getScreensSortedByPosition()`,
so it follows physical order rather than serial or connector. Assignments
therefore survive replugging, which renumbers connectors (DP-9 -> DP-11 and so
on). That state directory is not tracked, so the assignment itself lives outside
this repo; only the images here are versioned.
