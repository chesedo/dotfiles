# Dotfiles Agent Instructions

## Repository layout

| Path | Purpose |
|------|---------|
| `home-manager/` | Home Manager user config |
| `home-manager/claude/` | Claude Code config files (`settings.json`, `statusline.sh`, `AGENTS.md`) |
| `nixos/` | NixOS system config |
| `scripts/` | Shell scripts referenced by Home Manager packages |
| `eww/`, `leftwm/` | Desktop environment config (symlinked via `xdg.configFile`) |
| `.doom.d/` | Emacs/Doom config (symlinked via `home.file`) |

## Home Manager conventions

### Prefer out-of-store symlinks for mutable files

Use `config.lib.file.mkOutOfStoreSymlink` when a file needs to remain writable at runtime (e.g. a TUI or tool writes back to it) or when frequent manual edits are expected:

```nix
home.file.".some/config.json" = {
  source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/path/to/config.json";
};
```

Use declarative options (e.g. `programs.foo.settings`) only for config that is fully owned by Nix and never written to by other tools.

### New config files belong in a named subfolder

Group related config files under a dedicated subfolder in `home-manager/` rather than placing them flat. For example, all Claude Code files live under `home-manager/claude/`.

## Keeping this file up to date

If a conversation contains corrections to something documented here (or reveals a convention not yet captured), ask the user whether `AGENTS.md` should be updated to reflect it before closing out.
