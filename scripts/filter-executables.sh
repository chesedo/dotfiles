#!/usr/bin/env sh

# This script filters the list of executables based on user input
# and outputs the results as a JSON array for eww

# Define cache location
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/eww"
CACHE_FILE="$CACHE_DIR/executables.cache"

# Get search query from command line argument
query="$1"

# Check if cache exists, if not create it
if [[ ! -f "$CACHE_FILE" ]]; then
    echo "Cache not found, creating it..."
    $(dirname "$0")/update-executables-cache.sh
fi

# Filter executables based on query
if [ -z "$query" ]; then
    # If query is empty, use all executables
    filtered_list=$("$CACHE_FILE")
else
    # Filter using grep (case insensitive)
    filtered_list=$(grep -i "$query" "$CACHE_FILE")
fi

filtered_list=$(head -n 10 <<< "$filtered_list") # Limit to 10 results

# Convert to JSON array for eww
json_array="["
first=true

while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    if [ "$first" = true ]; then
        first=false
    else
        json_array+=","
    fi

    # Escape special characters for JSON
    escaped_line=$(echo "$line" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
    json_array+="\"$escaped_line\""
done <<< "$filtered_list"

json_array+="]"
echo "$json_array"

eww update launcher_results="$json_array"
