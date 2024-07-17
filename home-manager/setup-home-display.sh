# Read monitor information from AUTORANDR_MONITORS
IFS=':' read -ra MONITORS <<< "$AUTORANDR_MONITORS"

# Assign output names
LAPTOP_OUTPUT=${MONITORS[0]}  # eDP-1
LEFT_OUTPUT=${MONITORS[1]}    # DP-9 most of the time
RIGHT_OUTPUT=${MONITORS[2]}   # DP-10 most of the time

# Initial setup to force update
xrandr --fb 1269x846 \
    --output "$LEFT_OUTPUT" --off \
    --output "$RIGHT_OUTPUT" --off \
    --output "$LAPTOP_OUTPUT" --mode 2256x1504 --pos 0x0 --rate 60.00 --reflect normal --rotate normal --scale 0.562500x0.562500

# Final setup
xrandr --fb 4356x2584 \
    --output "$LEFT_OUTPUT" --mode 1920x1080 --pos 0x0 --primary --rate 60.00 --reflect normal --rotate normal \
    --output "$RIGHT_OUTPUT" --mode 1920x1080 --pos 1920x0 --rate 60.00 --reflect normal --rotate normal \
    --output "$LAPTOP_OUTPUT" --mode 2256x1504 --pos 2100x1080 --rate 60.00 --reflect normal --rotate normal --scale 0.562500x0.562500
