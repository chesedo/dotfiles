#!/usr/bin/env sh
# Script to update EWW notification variable when dunst receives a notification

# Get system boot time (current time - uptime)
boot_time=$(date +%s)
uptime_seconds=$(awk '{print int($1)}' /proc/uptime)
boot_time=$((boot_time - uptime_seconds))

# Simplify and group notifications by appname, adding formatted timestamps
grouped=$(dunstctl history | jq --argjson boot_time "$boot_time" '
  .data[0] | map({
    id: .id.data,
    appname: .appname.data,
    summary: .summary.data,
    body: .body.data,
    message: .message.data,
    timestamp: .timestamp.data,
    timestamp_formatted: (($boot_time + (.timestamp.data / 1000000)) | strflocaltime("%H:%M")),
    urgency: (.urgency.data | ascii_downcase),
    icon_path: .icon_path.data,
    category: .category.data
  }) |
  group_by(.appname) |
  map({
    appname: .[0].appname,
    count: length,
    notifications: . | sort_by(.timestamp) | reverse
  })
')

# Update EWW with grouped notification data
eww update notification_groups="$grouped"
