# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language

The maintainer of this project is a Chinese speaker. Reply to questions about this project in Chinese or English. Keep code comments, commit messages, and other in-repo changes in English.

## What this is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot) (vendored as a git submodule in `dotbot/`). `install.conf.yaml` declares the symlinks dotbot creates from this repo into `$HOME` and `~/.config`. The repo lives at `~/.config/dotfiles` (`$DOTFILES_HOME`).

The interactive shell is [**fish**](https://fishshell.com). (The previous zsh setup is preserved on the `zsh-legacy` branch.)

## Commands

- `./install` — apply the config: syncs the dotbot submodule, then runs dotbot against `install.conf.yaml` to (re)create all symlinks. Idempotent; run after changing `install.conf.yaml` or adding new config files. Pass-through args go to dotbot.
- There is no build/test/lint suite — this is a config repo. Validate fish changes by syntax-checking (`fish -n shell/fish/config.fish`) and/or starting a fresh shell (`fish -c exit`, should be clean). Use `fish --profile <file> -c exit` to capture a startup profile.
- Editing a file under `shell/fish/` takes effect on the next shell start (no reinstall needed — `config.fish` is symlinked and sources the rest by absolute path). Reinstall is only needed when adding a *new* link entry to `install.conf.yaml`.

## Shell config architecture

The fish setup is deliberately layered under `shell/fish/` so each concern is isolated and OS/host-specific code stays out of the common path. Fish reads `config.fish` for **all** shells (there is no `.zshenv`/`.zshrc` split), so environment/PATH runs unconditionally and interactive-only work is gated behind `status is-interactive`.

`shell/fish/config.fish` (the only file symlinked, to `~/.config/fish/config.fish`) sources, in order:

1. `lib/guards.fish` — must load first; defines the helper vocabulary the rest of the repo depends on, plus the cached `$DOTFILES_OS` / `$DOTFILES_HOST` globals.
2. `env/base.fish` → `env/os/$DOTFILES_OS.fish` → `env/host/$DOTFILES_HOST.fish` — environment/PATH, most-general to most-specific (all shells).
3. `functions/guarded_commands.fish` — country-guarded command wrappers (all shells; see "Where things go").
4. **(interactive only)** `functions/proxy.fish`, `login/base.fish`, `interactive/base.fish`, then a `proxy` call.

Like the old zsh layout, only `config.fish` (and `fish_plugins`) are symlinked; the layered files are sourced by absolute path from `$DOTFILES_FISH_HOME` (`$DOTFILES_HOME/shell/fish`).

### Conventions (defined in `lib/guards.fish`)

All config files use these helpers instead of raw conditionals — match this style when adding code:

- `source_if_file <path>` — source only if the file exists (used everywhere for optional/host-specific files).
- `has_cmd <cmd>` / `require_cmds <cmd...>` — check command availability (over `type -q`); `require_cmds` reports all missing and returns 1 (use at the top of functions to guard).
- `run_if_cmd <cmd> <string>` — `eval` an init string only when the command exists (fish tool inits more commonly use `tool init … | source`).
- `path_append_if_dir` / `path_prepend_if_dir` — add to PATH only if the dir exists (thin guards over `fish_add_path -ga` / `-gp`, which dedupe automatically).
- `_dotfiles_ip_country` — detect the effective egress country via `curl https://ipinfo.io/country` (honors `http_proxy`, so it reflects the proxy exit). No caching: probes live on every call (2s timeout) so it always tracks the current proxy state. Echoes the 2-letter code, or returns 1 with no output on failure.
- `require_country_not <cc...>` — guard that succeeds only when the egress country is known and **not** in the given list; **fail-closed** (an undeterminable country also fails). Idiom: `require_country_not CN; or return 1`. Set `DOTFILES_NO_COUNTRY_GUARD=1` to bypass (escape hatch, since fail-closed blocks when offline).
- `$DOTFILES_OS` (`Darwin`/`Linux`) and `$DOTFILES_HOST` (short hostname) are computed once and cached as exported globals. Branch on these rather than re-running `uname`.

### Where things go

- **OS-specific** env → `env/os/{Darwin,Linux}.fish`; OS-specific interactive setup → branch on `$DOTFILES_OS` (via `switch`) in `interactive/base.fish`.
- **Host-specific** env → `env/host/<shorthostname>.fish` (only sourced on that machine; safe to add per-machine PATH/tweaks).
- **Functions** → fish autoloads on demand from its `functions/` path, but this repo sources specific files explicitly from `config.fish`: `functions/proxy.fish` (interactive) and `functions/guarded_commands.fish` (all shells). The custom utility functions/aliases from the zsh setup (archive/git/llvm/format/clipboard/diff/system tools, eza/bat/fd aliases) were intentionally **not** ported — see them on the `zsh-legacy` branch.
- **Country-guarded command wrappers** → `functions/guarded_commands.fish`. Each wrapper (e.g. `claude`) calls `require_country_not CN; or return 1` then `command <name> $argv`. A fish function only shadows the **bare** command name, so path invocations (`./claude`, `~/.local/bin/claude`, absolute paths) bypass the guard by design — no shell hook can block a path-based exec.

### Tool inits

- Interactive inits live in `login/base.fish` (fzf) and `interactive/base.fish` (Homebrew `shellenv`, OrbStack, zoxide). **zoxide must init last** (hook ordering).
- Fish provides syntax highlighting, autosuggestions, and history search natively — the zsh-users plugins that supplied those under Zim are no longer needed.

## Plugin manager (fisher)

Plugins are managed by [fisher](https://github.com/jorgebucaran/fisher). The manifest lives in `shell/fish/fish_plugins` (symlinked to `~/.config/fish/fish_plugins`); `interactive/base.fish` auto-bootstraps fisher on first run if it's missing. After editing `fish_plugins`, run `fisher update`. Current plugins: `jorgebucaran/nvm.fish` (Node/`nvm`).

There is **no prompt configured** — fish uses its default. To get a powerlevel10k-style prompt, add [`IlanCosman/tide`](https://github.com/IlanCosman/tide) to `fish_plugins`, `fisher update`, then run `tide configure` (a wizard like `p10k configure`). Note: powerlevel10k itself is zsh-only and cannot run in fish. [Starship](https://starship.rs) is a cross-shell alternative (`starship init fish | source`).

## App configs

`apps_config/` holds standalone tool configs symlinked into `~/.config` (nvim — LazyVim-based, clangd, wezterm, yazi, tmux). `scripts/` is symlinked to `~/scripts` and holds standalone Python/LLDB helpers. These are independent of the shell layering above.

## Mirrors / region note

`env/base.fish` sets China-region mirrors (`HF_ENDPOINT` → hf-mirror.com, Rustup → USTC mirror). Keep this in mind when adding download/install logic. Proxy config lives in `~/.config/proxychains.conf` (a proxychains-ng config): the `proxy` function (`functions/proxy.fish`) parses its first `[ProxyList]` entry into `http_proxy`/`https_proxy`/`all_proxy`, and `prox <cmd>` runs a single command through `proxychains4 -f` using the same file.

## Known fish-vs-zsh gotchas

- `~/.cargo/env` is POSIX-only; fish uses `~/.cargo/env.fish` (rustup writes both).
- Proxy config now lives in `~/.config/proxychains.conf` (read by both `proxy` and `prox`). The old `~/set_proxy.sh` / `$http_proxy_server` mechanism was removed — if the config file is absent, `proxy` offers to write a template and `prox` writes one then aborts.
- NVM has no native fish support; it's provided by the `nvm.fish` plugin and does not see Node versions previously installed under `~/.nvm`.
