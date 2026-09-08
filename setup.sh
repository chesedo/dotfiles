#!/bin/sh
# Bring a machine up from a fresh NixOS install. Both layers come from
# flake.lock, so no channels are involved.
set -eu

if [ "$(id -u)" -eq 0 ]; then
	echo "Run this as yourself, not root -- setup-nixos.sh sudos on its own," >&2
	echo "and the user layer has to land in your profile, not root's." >&2
	exit 1
fi

cd "$(dirname "$0")"

# home.nix reaches back to ~/dotfiles by absolute path, for secrets.nix and for
# every mkOutOfStoreSymlink, so the clone genuinely has to be there.
if [ "$PWD" != "$HOME/dotfiles" ] &&
	[ "$(pwd -P)" != "$(cd "$HOME" && pwd -P)/dotfiles" ]; then
	echo "This repo has to live at $HOME/dotfiles; it is at $(pwd -P)." >&2
	exit 1
fi

# System layer first. It needs no secrets, and it is what installs the desktop
# and the home-manager CLI the user layer is run with.
./setup-nixos.sh

# secrets.nix is gitignored, and home.nix reads jiraApiToken unguarded, so the
# user layer cannot evaluate until it exists.
if [ ! -f home-manager/secrets.nix ]; then
	cat > home-manager/secrets.nix <<-'EOF'
		{
		  jiraApiToken = "";
		  googleCalendars = { };
		}
	EOF
	echo "Wrote a placeholder home-manager/secrets.nix -- fill it in, then run" >&2
	echo "this again. Stopping rather than activating a jiratui config that" >&2
	echo "cannot authenticate." >&2
	exit 1
fi

# --impure because home.nix locates secrets.nix through $HOME.
home-manager switch --flake ".#chesedo" --impure
