#!/usr/bin/env sh

upower -m | while read -r line; do
    jc upower -d \
        | jq '.[] | select(.type == "Device" and (.detail.type | contains("battery") or contains("mouse") or contains("keyboard")) and (.device_name | contains("Display") | not)) | { model, updated } + .detail + { updated_seconds_ago }' \
        | jq '. | .model //= "Laptop" | .type_icon = if .type == "battery" then "󰌢" elif .type == "mouse" then "󰍽" elif .type == "keyboard" then "󰌌" else "󰂑" end | .level_icon = if .state == "charging" then "󰂄" else "󰂃" end' \
        | jq '. |= . + { "last_updated": (
  if .updated_seconds_ago < 60 then "\(.updated_seconds_ago)s"
  elif .updated_seconds_ago < 3600 then "\(.updated_seconds_ago / 60 | floor)m"
  else "\(.updated_seconds_ago / 3600 | floor)h"
  end
), "time_label": (
  if (.time_to_empty | type) == "number" then
    if .time_to_empty_unit == "hours" then "\(.time_to_empty | floor)h \(((.time_to_empty - (.time_to_empty | floor)) * 60) | round)m left"
    else "\(.time_to_empty | round)m left" end
  elif (.time_to_full | type) == "number" then
    if .time_to_full_unit == "hours" then "\(.time_to_full | floor)h \(((.time_to_full - (.time_to_full | floor)) * 60) | round)m to full"
    else "\(.time_to_full | round)m to full" end
  else "" end
)}' \
        | jq --slurp --compact-output
done
