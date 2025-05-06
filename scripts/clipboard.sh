#!/usr/bin/env sh
#
# Clipcat finder that processes clipcatctl output to JSON
# and sets an eww variable
# Usage: ./clipboard.sh [--toggle]

# Parse arguments
TOGGLE_WINDOW=false

if [ "$1" = "--toggle" ]; then
    TOGGLE_WINDOW=true
fi

# Get clipboard items from clipcatctl
CLIPBOARD_DATA=$(clipcatctl list)

# Convert clipboard entries to JSON array
echo "[" > /tmp/clipboard_items.json
FIRST=true

# Process each line
echo "$CLIPBOARD_DATA" | while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Extract hash ID and content
    hash_id=$(echo "$line" | cut -d: -f1)

    # Extract content (everything after the first colon)
    raw_content="${line#*: }"

    # Add comma separator for JSON array elements (except for the first one)
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> /tmp/clipboard_items.json
    fi

    # Escape special characters for JSON
    content=$(echo "$raw_content" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g' | sed 's/\t/\\t/g')

    # Write entry as JSON object
    cat << EOF >> /tmp/clipboard_items.json
  {
    "id": "$hash_id",
    "content": "$content"
  }
EOF

done

# Close JSON array
echo "]" >> /tmp/clipboard_items.json

# Set eww variable with the JSON data
eww update clipboard_items="$(cat /tmp/clipboard_items.json)"

if [ "$TOGGLE_WINDOW" = true ]; then
    eww open --toggle clipboard
fi

# We don't need to return anything since we're not using this as a standard finder anymore
# But if the script is called from clipcat-menu, output something so it doesn't break
echo "Clipboard data processed"
