When instructions are vague or could be interpreted in multiple ways, ask specific clarifying questions before responding. Do not make assumptions — identify what is unclear and ask targeted questions to resolve the ambiguity.

When asked to commit, only stage and commit files that were changed during the current conversation. Do not include unrelated modified or untracked files that were already present before the conversation started.

## Pre-commit review loop

Before creating any git commit, review the staged change with a fresh sub-agent. This review must happen after staging and before running `git commit` — do not stage, draft a message, and commit in one go.

1. Stage exactly the files that will be committed (see the rule above) so the sub-agent only sees that subset. If unrelated changes exist in the working tree, keep them unstaged — the sub-agent should review `git diff --cached`, not the full working-tree diff.
2. Spawn a new sub-agent (do not reuse or continue a previous one) with no context about earlier reviews in this conversation. Give it only the staged diff and the goal of reviewing it in isolation. Each iteration must be a fresh spawn so the review is independent.
3. Critically analyze the sub-agent's feedback yourself — do not blindly apply it. Decide which points are worth acting on and which to reject, and explain your reasoning briefly.
4. If you make changes in response, re-stage and loop back to step 2 with another fresh sub-agent.
5. Only create the commit once a review iteration returns no comments you judge worth acting on.

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
