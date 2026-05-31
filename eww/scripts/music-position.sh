#!/usr/bin/env bash
# Polls playback position, freezing when paused to handle buggy MPRIS players

pos_file="/tmp/eww_music_pos"

while true; do
  status=$(playerctl status 2>/dev/null || echo "Stopped")

  if [[ "$status" == "Playing" ]]; then
    pos=$(playerctl position 2>/dev/null || echo 0)
    echo "$pos" > "$pos_file"
  else
    pos=$(cat "$pos_file" 2>/dev/null || echo 0)
  fi

  secs=$(printf "%.0f" "$pos")
  printf '{"value":%s,"fmt":"%d:%02d"}\n' "$pos" $((secs / 60)) $((secs % 60))
  sleep 1
done
