When instructions are vague or could be interpreted in multiple ways, ask specific clarifying questions before responding. Do not make assumptions — identify what is unclear and ask targeted questions to resolve the ambiguity.

When asked to commit, only stage and commit files that were changed during the current conversation. Do not include unrelated modified or untracked files that were already present before the conversation started.

## Prefer installed tools over ad-hoc shell pipelines

The following tools are available — use them instead of piping output through grep, awk, cut, or python:

- `jq` — parse and query JSON (not `python3 -c "import json..."` or `grep | cut`)
- `rg` (ripgrep) — search file contents (not `grep -r`)
- `fd` — find files by name or pattern (not `find . -name`)
- `jc` — converts common CLI output (ls, ps, etc.) into JSON for structured processing
- `sqlite3` — query SQLite databases directly

## Write full output to a temp file before inspecting

When a command produces output that needs to be inspected or filtered, write the complete output to `$TMPDIR` first, then use the Read tool or the above utilities to extract the relevant parts. Do not re-run the original command with a tighter grep — run it once, capture everything, then query the result.
