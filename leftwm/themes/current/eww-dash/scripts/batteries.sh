#!/usr/bin/env sh

upower -m | while read -r line; do
    jc upower -d \
        | jq '.[] | select(.type == "Device" and (.detail.type | contains("battery") or contains("mouse") or contains("keyboard")) and (.device_name | contains("Display") | not)) | { model, updated } + .detail + { updated_seconds_ago }' \
        | jq '. | .model //= "Laptop" | .type_icon = if .type == "battery" then "󰌢" elif .type == "mouse" then "󰍽" elif .type == "keyboard" then "󰌌" else "󰂑" end' \
        | jq --slurp --compact-output
done
