input=$(cat)

# Parse JSON data
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
time_str=$(date +%H:%M)

# Shorten home directory to ~
short_dir="${cwd/#$HOME/~}"

# Truncate to at most 3 path segments (mirrors starship truncation_length=3)
IFS='/' read -ra parts <<< "$short_dir"
total=${#parts[@]}
if [ "$total" -gt 3 ]; then
  short_dir="…/${parts[$((total-2))]}/${parts[$((total-1))]}/${parts[$((total))]}"
fi

# Git branch (skip optional locks, mirrors starship git_branch symbol)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -n "$branch" ] && git_branch=$' \033[0;35m '"$branch"$'\033[0m'
fi

# Context window usage percentage with color coding
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage')
if [ "$context_pct" -lt 50 ]; then
  context_info=$' \033[0;32m'"$context_pct"$'%\033[0m'
elif [ "$context_pct" -lt 80 ]; then
  context_info=$' \033[0;33m'"$context_pct"$'%\033[0m'
else
  context_info=$' \033[0;31m'"$context_pct"$'%\033[0m'
fi

# Cost is pre-calculated by Claude Code (rounded to 2 decimals)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd' | xargs printf "%.2f")
cost_info=$' \033[0;33m$'"$cost"$'\033[0m'

# Token usage info
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size')
current_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens')
current_output=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens')
current_total=$((cache_creation + cache_read))

# Line 1: Time | Directory | Git
printf "\033[0;90m%s\033[0m \033[0;34m%s\033[0m%s\n" \
  "$time_str" \
  "$short_dir" \
  "$git_branch"

# Line 2: Model | Cost
printf "\033[0;90m├─\033[0m \033[0;36m[%s]\033[0m %s\n" \
  "$model" \
  "$cost_info"

# Line 3: Session token totals with context usage
printf "\033[0;90m├─ Session:\033[0m \033[0;36m%5d in\033[0m \033[0;35m%5d out\033[0m  \033[0;90m│\033[0m  \033[0;34m%d\033[0m of \033[0;90m%d\033[0m (%s)\n" \
  "$total_input" \
  "$total_output" \
  "$current_total" \
  "$context_size" \
  "$context_info"

# Line 4: Current message tokens
printf "\033[0;90m└─ Current:\033[0m \033[0;36m%3d in\033[0m \033[0;35m%3d out\033[0m\n" \
  "$current_input" \
  "$current_output"
