#!/usr/bin/env bash
#
# Populate git submodules in a linked worktree, from Claude Code's
# SubagentStart / SessionStart hooks (both start with cwd inside the worktree).
# Silent no-op anywhere else, since those hooks fire on every session.
#
# `git worktree add` leaves submodules empty, and `git submodule update --init`
# re-clones every one of them from its remote: slow, and impossible from a
# sandboxed session. Cloning from the main checkout's module gitdir instead is a
# local path on the same filesystem, so git hardlinks the objects. Each worktree
# gets its own submodule gitdir, so the main checkout is left alone.
#
# Alternates (--reference, submodule.alternateLocation) cannot replace this:
# clone contacts the remote even when every object is already local.
#
# Strictly offline: hooks run unsandboxed with real credentials, so a pin the
# local cache lacks is reported, never fetched.

set -euo pipefail

toplevel=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
gitdir=$(git rev-parse --absolute-git-dir)
common=$(git rev-parse --path-format=absolute --git-common-dir)
[[ $gitdir != "$common" ]] || exit 0

# Both hook events can fire at one worktree at once, and concurrent runs collide
# in git's clone bookkeeping, leaving a tree half populated.
exec 9> "$gitdir/worktree-submodules.lock" || exit 0
flock -w 60 9 || {
  echo "worktree-submodules: could not take $gitdir/worktree-submodules.lock" >&2
  exit 0
}

# Populate one level, then recurse: git mirrors its own layout for nested
# submodules, so a child's source gitdir is <parent gitdir>/modules/<name>.
init_level() {
  local repo=$1 src_base=$2 key name path sha src

  [[ -f $repo/.gitmodules ]] || return 0

  while read -r key path; do
    name=${key#submodule.}
    name=${name%.path}
    # The index entry, not HEAD: that is what `submodule update` checks out.
    sha=$(git -C "$repo" rev-parse ":$path" 2> /dev/null) || continue
    src="$src_base/$name"

    # Only populate an absent submodule. One sitting at a different commit may
    # have been moved deliberately, and these hooks also fire on resume and
    # compact, so resetting it would orphan that work.
    if [[ ! -e $repo/$path/.git ]]; then
      # GIT_WORK_TREE=. because the module gitdir's core.worktree points into
      # the main checkout; git chdirs there first and fails if it is gone.
      if GIT_WORK_TREE=. git --git-dir="$src" cat-file -e "$sha^{commit}" 2> /dev/null; then
        # Passed with -c, never registered: at the top level the parent's config
        # is shared with the main checkout, and url/active/update are exactly
        # the keys `submodule init` would otherwise persist there.
        # protocol.file.allow is "never" for submodule clones by default
        # (CVE-2022-39253); this URL is one we built, not one read from the file.
        git -C "$repo" -c "submodule.$name.url=$src" \
          -c "submodule.$name.active=true" -c "submodule.$name.update=checkout" \
          -c protocol.file.allow=always \
          submodule update --init --quiet -- "$path" ||
          echo "worktree-submodules: failed to populate $repo/$path" >&2
      else
        echo "worktree-submodules: $repo/$path pins ${sha:0:8}, which the main" \
          "checkout has never fetched; run 'git submodule update --init" \
          "--recursive' there and new worktrees will pick it up" >&2
      fi
    fi

    init_level "$repo/$path" "$src/modules"
  done < <(git -C "$repo" config -f .gitmodules --get-regexp '^submodule\..*\.path$')
}

init_level "$toplevel" "$common/modules"
