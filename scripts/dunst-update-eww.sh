#!/run/current-system/sw/bin/bash
# Script to update EWW notification variable when dunst receives a notification

TRIGGER_FIFO="/tmp/dunst-eww-trigger"

[[ -p "$TRIGGER_FIFO" ]] || mkfifo "$TRIGGER_FIFO"
exec 3<> "$TRIGGER_FIFO"

trap 'kill 0; exec 3>&-; rm -f "$TRIGGER_FIFO"' EXIT

emit_groups() {
    local boot_time uptime_seconds
    boot_time=$(date +%s)
    uptime_seconds=$(awk '{print int($1)}' /proc/uptime)
    boot_time=$((boot_time - uptime_seconds))

    dunstctl history | jq --unbuffered -c --argjson boot_time "$boot_time" '
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
        subgroups: (group_by(.summary) | map({
          summary: .[0].summary,
          count: length,
          notifications: (sort_by(.timestamp) | reverse)
        }))
      })
    '
}

emit_groups

dbus-monitor --session \
    "type='method_call',interface='org.freedesktop.Notifications',member='Notify'" \
    "type='signal',interface='org.freedesktop.Notifications',member='NotificationClosed'" \
    2>/dev/null \
    | grep --line-buffered -E "member=(Notify|NotificationClosed)" \
    | while IFS= read -r _; do
        echo 1 >&3
      done &

while IFS= read -r _ <&3; do
    emit_groups
    # Drain any buffered events to debounce rapid bursts
    while IFS= read -r -t 0.1 _ <&3; do :; done
done
