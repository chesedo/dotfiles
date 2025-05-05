#!/usr/bin/env sh

upower -m | while read -r line; do
    jc upower -d \
        | jq '.[] | select(.type == "Device" and (.detail.type | contains("battery") or contains("mouse") or contains("keyboard")) and (.device_name | contains("Display") | not)) | { model, updated } + .detail + { updated_seconds_ago }' \
        | jq '. | .model //= "Laptop" | .type_icon = if .type == "battery" then "󰌢" elif .type == "mouse" then "󰍽" elif .type == "keyboard" then "󰌌" else "󰂑" end' \
        | jq '. |= . + { "last_updated": (
  if .updated_seconds_ago < 60 then "\(.updated_seconds_ago)s"
  elif .updated_seconds_ago < 3600 then "\(.updated_seconds_ago / 60 | floor)m"
  else "\(.updated_seconds_ago / 3600 | floor)h"
  end
)}' \
        | jq --slurp --compact-output
done
