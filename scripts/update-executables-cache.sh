#!/usr/bin/env sh

# This script lists all executables in PATH directories
# and writes them to a cache file, one entry per line

# Define cache location
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/eww"
CACHE_FILE="$CACHE_DIR/executables.cache"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Function to check if a file is executable by the current user
is_executable() {
    [[ -f "$1" && -x "$1" ]]
}

# Create a temporary file for building the cache
TMP_CACHE=$(mktemp)

# Loop through each directory in PATH
IFS=':' read -ra path_dirs <<< "$PATH"
for dir in "${path_dirs[@]}"; do
    # Skip if path component doesn't exist
    [[ -e "$dir" ]] || continue

    # Resolve symlinked directory if needed
    real_dir=$(readlink -f "$dir" 2>/dev/null)

    # Skip if resolved directory doesn't exist or isn't readable
    [[ -d "$real_dir" && -r "$real_dir" ]] || continue

    # Find all executable files in this directory (including symlinks)
    while IFS= read -r -d '' file; do
        # For symlinks, check if they point to executable files
        if [[ -L "$file" ]]; then
            target=$(readlink -f "$file" 2>/dev/null)
            if [[ -f "$target" && -x "$target" ]]; then
                name=$(basename "$file")
                echo "$name" >> "$TMP_CACHE"
            fi
        # For regular files, check if they're executable
        elif is_executable "$file"; then
            name=$(basename "$file")
            echo "$name" >> "$TMP_CACHE"
        fi
    done < <(find "$real_dir" -maxdepth 1 \( -type f -o -type l \) -print0 2>/dev/null)
done

# Sort and remove duplicates
sort -u "$TMP_CACHE" > "$CACHE_FILE"

# Clean up the temporary file
rm "$TMP_CACHE"

echo "Executable cache updated at $CACHE_FILE with $(wc -l < "$CACHE_FILE") entries"
