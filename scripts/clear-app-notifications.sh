#!/usr/bin/env sh
# Script to clear all notifications for a specific app
# Usage: clear-app-notifications "appname"

appname="$1"

if [ -z "$appname" ]; then
    echo "Usage: clear-app-notifications 'appname'"
    exit 1
fi

# Get all notification IDs for this app and remove them
dunstctl history | jq -r "
  .data[0] |
  map(select(.appname.data == \"$appname\")) |
  .[].id.data
" | while read -r id; do
    if [ -n "$id" ]; then
        dunstctl history-rm "$id"
    fi
done

# Trigger notification update
echo 1 > /tmp/dunst-eww-trigger
