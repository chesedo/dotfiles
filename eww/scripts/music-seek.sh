#!/usr/bin/env bash
# Seeks only when position differs from the cached value by >3s,
# preventing the onchange feedback loop from 1-second position poll updates.
requested="$1"
current=$(cat /tmp/eww_music_pos 2>/dev/null || echo 0)
diff=$(awk "BEGIN{d=$current - $requested; print (d<0?-d:d)}")
if awk "BEGIN{exit ($diff > 3 ? 0 : 1)}"; then
    playerctl position "$requested"
fi
