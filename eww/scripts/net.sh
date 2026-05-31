#!/usr/bin/env bash
# Streams {"down": N, "up": N} bytes/sec for the active route interface

prev_rx=0
prev_tx=0
first=true

while true; do
  iface=$(ip route get 1.1.1.1 2>/dev/null \
    | awk 'NR==1{ for(i=1;i<=NF;i++) if($i=="dev") { print $(i+1); exit } }')

  if [[ -z "$iface" ]]; then
    echo '{"down":0,"up":0,"iface":""}'
    sleep 2
    continue
  fi

  # /proc/net/dev: iface: rx_bytes(2) ... tx_bytes(10)
  read -r rx tx <<< "$(awk -v iface="${iface}:" '$1==iface {print $2, $10}' /proc/net/dev)"

  if [[ "$first" == "false" && -n "$rx" && -n "$tx" ]]; then
    down=$(( rx - prev_rx ))
    up=$(( tx - prev_tx ))
    [[ $down -lt 0 ]] && down=0
    [[ $up -lt 0 ]] && up=0
    printf '{"down":%d,"up":%d,"iface":"%s"}\n' "$down" "$up" "$iface"
  fi

  prev_rx=$rx
  prev_tx=$tx
  first=false
  sleep 1
done
