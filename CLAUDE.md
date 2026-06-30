# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot) (vendored as a git submodule in `dotbot/`). `install.conf.yaml` declares the symlinks dotbot creates from this repo into `$HOME` and `~/.config`. The repo lives at `~/.config/dotfiles` (`$DOTFILES_HOME`).

## Commands

- `./install` — apply the config: syncs the dotbot submodule, then runs dotbot against `install.conf.yaml` to (re)create all symlinks. Idempotent; run after changing `install.conf.yaml` or adding new config files. Pass-through args go to dotbot.
- There is no build/test/lint suite — this is a config repo. Validate shell changes by sourcing in a fresh shell: `zsh -ic exit` (should be clean), or `DOTFILES_PROFILE=1 zsh -ic exit` to print a `zprof` startup-time profile.
- Editing a file that is already symlinked (e.g. `shell/.zshrc`) takes effect immediately — no reinstall needed. Reinstall is only needed when adding a *new* link entry to `install.conf.yaml`.

## Shell config architecture

The zsh setup is deliberately layered and split across `shell/zsh/` so each concern is isolated and OS/host-specific code stays out of the common path. Two entry points, loaded by zsh in order:

1. **`shell/.zshenv`** (all shells, including non-interactive) sources, in order:
   - `zsh/lib/guards.zsh` — must load first; defines the helper vocabulary the rest of the repo depends on.
   - `zsh/env/base.zsh` → `zsh/env/os/$DOTFILES_OS.zsh` → `zsh/env/host/$DOTFILES_HOST.zsh` — environment/PATH, most-general to most-specific.
2. **`shell/.zshrc`** (interactive shells) sources `zsh/login/base.zsh`, `zsh/interactive/base.zsh`, then `zsh/functions/base.zsh`.

### Conventions (defined in `zsh/lib/guards.zsh`)

All config files use these helpers instead of raw conditionals — match this style when adding code:

- `source_if_file <path>` — source only if the file exists (used everywhere for optional/host-specific files).
- `has_cmd <cmd>` / `require_cmds <cmd...>` — check command availability; `require_cmds` reports all missing and returns 1 (use at the top of functions to guard).
- `run_if_cmd <cmd> <string>` — `eval` an init string only when the command exists (used for `eval "$(tool init)"` patterns: brew, zoxide, fzf).
- `path_append_if_dir` / `path_prepend_if_dir` — add to PATH only if the dir exists and isn't already present (idempotent).
- `$DOTFILES_OS` (`Darwin`/`Linux`) and `$DOTFILES_HOST` (short hostname) are computed once and cached as exported globals to avoid a `uname`/`hostname` fork per shell. Branch on these rather than re-running `uname`.

### Where things go

- **OS-specific** env → `zsh/env/os/{Darwin,Linux}.zsh`; OS-specific interactive setup → branch on `$DOTFILES_OS` in `zsh/interactive/base.zsh`.
- **Host-specific** env → `zsh/env/host/<shorthostname>.zsh` (only sourced on that machine; safe to add per-machine PATH/tweaks).
- **Functions/aliases** → one file per domain under `zsh/functions/` (git_tools, diff_tools, format_tools, archive_tools, network_tools, system_tools, clipboard, llvm, aliases_compat, compat_wrappers). New function files must be added to the source list in `zsh/functions/base.zsh` to load.
- Aliases that swap in modern tools (eza, bat, fd) live in `aliases_compat.zsh` and are guarded by `has_cmd` so they degrade gracefully across machines (note Linux `batcat`/`fdfind` naming).

### Startup-performance intent

Several patterns exist specifically to keep shell startup fast — preserve them:
- NVM is **lazy-loaded** in `zsh/login/base.zsh` via stub `nvm`/`node`/`npm`/`npx` functions that source NVM on first call.
- `skip_global_compinit=1` is set in `.zshenv`.
- Tool inits are gated behind `run_if_cmd` / interactive-only checks.

## Plugin manager (Zim)

Interactive shell loads [Zim](https://zimfw.org) via `apps_config/zim/setup_zim.zsh` (sourced from `interactive/base.zsh`). Module list lives in `shell/.zimrc`. After changing `.zimrc`, run `zimfw install` / `zimfw update` (or just start a new shell — `setup_zim.zsh` auto-reinstalls when `init.zsh` is older than `.zimrc`). Prompt is `asciiship` (p10k config in `apps_config/zim/.p10k.zsh` is present but currently commented out).

## App configs

`apps_config/` holds standalone tool configs symlinked into `~/.config` (nvim — LazyVim-based, clangd, wezterm, yazi, tmux). `scripts/` is symlinked to `~/scripts` and holds standalone Python/LLDB helpers. These are independent of the shell layering above.

## Mirrors / region note

`zsh/env/base.zsh` sets China-region mirrors (`HF_ENDPOINT` → hf-mirror.com, Rustup → USTC mirror). Keep this in mind when adding download/install logic.
