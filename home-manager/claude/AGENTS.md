When instructions are vague or could be interpreted in multiple ways, ask specific clarifying questions before responding. Do not make assumptions — identify what is unclear and ask targeted questions to resolve the ambiguity.

When asked to commit, only stage and commit files that were changed during the current conversation. Do not include unrelated modified or untracked files that were already present before the conversation started.

## Memory

Be sparing with memory. Do not create or update memory files (including `MEMORY.md`) proactively — always ask my explicit permission first, and only write the memory once I approve. Prefer not suggesting a memory update unless the fact is genuinely valuable and non-obvious.

## PR / issue bodies: no hard line-wrapping

Do not hard-wrap prose in PR descriptions, issue bodies, or PR review comments. Write each paragraph as one continuous line and let GitHub's renderer handle the wrapping — hard wraps ossify at whatever column you picked and look wrong on every other viewport width.

## Prefer installed tools over ad-hoc shell pipelines

The following tools are available — use them instead of piping output through grep, awk, cut, or python:

- `jq` — parse and query JSON (not `python3 -c "import json..."` or `grep | cut`)
- `rg` (ripgrep) — search file contents (not `grep -r`)
- `fd` — find files by name or pattern (not `find . -name`)
- `jc` — converts common CLI output (ls, ps, etc.) into JSON for structured processing
- `sqlite3` — query SQLite databases directly

## Write full output to a temp file before inspecting

When a command produces output that needs to be inspected or filtered, write the complete output to `$TMPDIR` first, then use the Read tool or the above utilities to extract the relevant parts. Do not re-run the original command with a tighter grep — run it once, capture everything, then query the result.

**This applies to every command whose output you inspect — builds, test runs, configure steps, one-off probes, everything.** Never pipe a command into `head`, `tail`, `grep`, `awk`, `sed`, or `wc` to peek at part of the output. Always redirect the full output (stdout + stderr) to a file under `$TMPDIR` with `> "$TMPDIR/<name>.log" 2>&1`, then use `Read` (with `offset`/`limit` for large files) or `rg`/`jq` against that file. If you catch yourself typing `| tail`, `| head`, `| grep`, etc. in a Bash invocation, stop and rewrite it as a redirect-then-Read. The whole point is that the full output stays on disk so you (or the user) can re-inspect earlier sections later — `| tail -40` destroys that ability.
