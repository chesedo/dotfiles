#!/usr/bin/env bash
# Fetches current conditions from wttr.in (auto-detects location by IP)

data=$(curl -sf "wttr.in/Pretoria?format=j1" 2>/dev/null) || {
  echo '{"temp":"?","condition":"Unavailable","high":"?","low":"?","icon":"?"}'
  exit
}

code=$(echo "$data"      | jq -r '.current_condition[0].weatherCode')
temp=$(echo "$data"      | jq -r '.current_condition[0].temp_C')
condition=$(echo "$data" | jq -r '.current_condition[0].weatherDesc[0].value')
high=$(echo "$data"      | jq -r '.weather[0].maxtempC')
low=$(echo "$data"       | jq -r '.weather[0].mintempC')

case "$code" in
  113)                                              icon="☀️"  ;;
  116)                                              icon="⛅"  ;;
  119|122)                                          icon="☁️"  ;;
  143|248|260)                                      icon="🌫️"  ;;
  200|386|389|392|395)                              icon="⛈️"  ;;
  227|230|323|326|329|332|335|338|350|368|371)      icon="❄️"  ;;
  176|263|266|293|296|299|302|305|308|353|356|359)  icon="🌧️"  ;;
  *)                                                icon="🌡️"  ;;
esac

printf '{"temp":"%s","condition":"%s","high":"%s","low":"%s","icon":"%s"}\n' \
  "$temp" "$condition" "$high" "$low" "$icon"
