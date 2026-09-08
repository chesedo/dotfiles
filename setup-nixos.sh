#!/bin/sh
# System layer. Flakes address a configuration by path, so nothing gets
# symlinked into /etc/nixos. The flake sees git-tracked files only, though: a
# newly created .nix file has to be `git add`ed before a rebuild will find it.
set -eu

cd "$(dirname "$0")"

sudo nixos-rebuild switch --flake ".#nixos-framework-13"
