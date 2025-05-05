#!/usr/bin/env sh

# Take screenshot with slop selection
sel=$(slop -f "-i %i -g %g" -c "0.91,0.52,0.42,0.8" -b 3 -p 10)
if [ $? -ne 0 ]; then
  # User canceled selection
  exit 1
fi

# Create temp file for screenshot
tmp_file="/tmp/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Take the screenshot and save to temp file
shotgun $sel "$tmp_file"

# Show eww widget to choose action
eww open --toggle screenshot-actions

# Pass the filename to eww as a variable
eww update screenshot-file="$tmp_file"
