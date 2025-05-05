#!/usr/bin/env sh

date +%M

while true; do
    current_second=$(date +%-S)  # Get the current second without leading zero
    sleep_seconds=$((60 - current_second))  # Calculate seconds to sleep until the next minute

    sleep "$sleep_seconds"

    date +%M
done
