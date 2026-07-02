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

The fish setup is organized as a **numbered stage model**. Fish has only two real config lifecycles — "all shells" (≈ zsh's `.zshenv`) and "interactive only" (≈ zsh's `.zshrc`); fish has **no** login/non-login split, so there is deliberately no separate "login" stage. `config.fish` is a thin orchestrator that bootstraps two variables, then sources each stage in order, gating stage 3 behind `status is-interactive`.

Each stage has a fixed charter — put new code in the stage whose charter it matches:

| Stage | Path | Runs for | Charter (what belongs here) |
|-------|------|----------|-----------------------------|
| 0 | `lib/guards.fish` | all shells, **first** | Helper vocabulary + cached `$DOTFILES_OS` / `$DOTFILES_HOST`. Definitions only — no side effects, no output, no PATH/env mutation. Everything below depends on it. |
| 1 | `env/` | all shells | Environment variables + PATH only. Idempotent, silent, no TTY assumptions, no tool inits. `base.fish` chains `os/$DOTFILES_OS.fish` → `host/$DOTFILES_HOST.fish` (general → specific). |
| 2 | `functions/` | all shells | Function & command-wrapper **definitions** (`guarded_commands`, `proxy`, `dotenv`), sourced via the `functions/base.fish` entrypoint. Defining is cheap and side-effect-free, so it runs for all shells (guards/wrappers then apply in scripts too). **Definitions only** — startup *calls* happen in stage 3. |
| 3 | `interactive/` | interactive only | Everything needing a TTY: tool inits (brew/fzf/zoxide/orbstack), prompt, keybindings, greeting, and startup actions (apply `proxy`, `.env` autoload). `base.fish` chains `interactive/os/$DOTFILES_OS.fish` (same base→os layering as `env/`); ordering matters (zoxide last). Absorbs the old `login/` stage. |

The order is not arbitrary: stage 0 defines the vocabulary everyone uses; stage 1 sets PATH before stage 2/3 probe for commands; stage 3 is last and gated so nothing interactive leaks into scripts.

`config.fish` sources exactly **four entrypoints** — `lib/guards.fish` (stage 0, a single file) and one `base.fish` per multi-file stage (`env/`, `functions/`, `interactive/`). Each `base.fish` owns the order of its own module's files; `config.fish` never enumerates a stage's inner files. Add a file to a stage by wiring it into that stage's `base.fish`, not into `config.fish`.

**Why not fish's native autoload?** Fish's canonical model is: `conf.d/*.fish` auto-sourced (alphabetically, *before* `config.fish`), `functions/` autoloaded one-function-per-file by filename, `completions/` likewise. We deliberately bypass all of that and source a curated list by absolute path from `$DOTFILES_FISH_HOME` (`$DOTFILES_HOME/shell/fish`) instead, because fisher writes plugin files into `~/.config/fish/{functions,conf.d,completions}` — keeping our own config out of those dirs stops plugin churn from polluting this repo. Consequence: our `functions/*.fish` group related functions by family (e.g. `proxy.fish` holds `proxy`/`prox`/`unproxy` + `_proxychains_*` helpers) rather than following the one-function-per-file autoload naming, since we source rather than autoload. Only `config.fish` and `fish_plugins` are symlinked into `~/.config/fish`.

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

- **OS-specific** env → `env/os/{Darwin,Linux}.fish`; OS-specific *interactive* setup → `interactive/os/$DOTFILES_OS.fish` (only `Darwin.fish` exists; Linux has none, and `source_if_file` no-ops on its absence). Both layers use the same base→os(→host) convention, so keep `switch $DOTFILES_OS` out of the `base.fish` files.
- **Host-specific** env → `env/host/<shorthostname>.fish` (only sourced on that machine; safe to add per-machine PATH/tweaks).
- **Functions** → fish autoloads on demand from its `functions/` path, but this repo sources them explicitly at stage 2 (all shells) via the `functions/base.fish` entrypoint, which chains `functions/guarded_commands.fish`, `functions/proxy.fish`, `functions/dotenv.fish`. Add a new function file by wiring it into `functions/base.fish` (not `config.fish`). These are definitions only; interactive *invocations* (the startup `proxy` call, `.env` autoload) live in `interactive/base.fish`. The custom utility functions/aliases from the zsh setup (archive/git/llvm/format/clipboard/diff/system tools, eza/bat/fd aliases) were intentionally **not** ported — see them on the `zsh-legacy` branch.
- **Country-guarded command wrappers** → `functions/guarded_commands.fish`. Each wrapper (e.g. `claude`) calls `require_country_not CN; or return 1` then `command <name> $argv`. A fish function only shadows the **bare** command name, so path invocations (`./claude`, `~/.local/bin/claude`, absolute paths) bypass the guard by design — no shell hook can block a path-based exec.

### Tool inits

- Interactive inits all live in stage 3: general ones (fzf, zoxide) in `interactive/base.fish`, macOS-only ones (Homebrew `shellenv`, OrbStack) in `interactive/os/Darwin.fish`. The os layer is sourced first (it extends PATH); **zoxide must init last** (hook ordering).
- Fish provides syntax highlighting, autosuggestions, and history search natively — the zsh-users plugins that supplied those under Zim are no longer needed.

## Plugin manager (fisher)

Plugins are managed by [fisher](https://github.com/jorgebucaran/fisher). The manifest lives in `shell/fish/fish_plugins` (symlinked to `~/.config/fish/fish_plugins`). fisher installs its own files into `~/.config/fish/{functions,conf.d,completions}` (not this repo). After editing `fish_plugins`, run `fisher update`. Current plugins: `fisher`, `jorgebucaran/nvm.fish` (Node/`nvm`), `pure-fish/pure` (prompt), `gazorby/fish-exa` (eza aliases), `jorgebucaran/autopair.fish`, `meaningful-ooo/sponge` (history cleanup), `edc/bass` (source POSIX scripts).

The prompt is [`pure-fish/pure`](https://github.com/pure-fish/pure) (a minimal async prompt, installed via `fish_plugins`). For a heavier powerlevel10k-style prompt, swap in [`IlanCosman/tide`](https://github.com/IlanCosman/tide) and run `tide configure` (a wizard like `p10k configure`); powerlevel10k itself is zsh-only and cannot run in fish. [Starship](https://starship.rs) is a cross-shell alternative (`starship init fish | source`).

## App configs

`apps_config/` holds standalone tool configs symlinked into `~/.config` (nvim — LazyVim-based, clangd, wezterm, yazi, tmux). `scripts/` is symlinked to `~/scripts` and holds standalone Python/LLDB helpers. These are independent of the shell layering above.

## Mirrors / region note

`env/base.fish` sets China-region mirrors (`HF_ENDPOINT` → hf-mirror.com, Rustup → USTC mirror). Keep this in mind when adding download/install logic. Proxy config lives in `~/.config/proxychains.conf` (a proxychains-ng config): the `proxy` function (`functions/proxy.fish`) parses its first `[ProxyList]` entry into `http_proxy`/`https_proxy`/`all_proxy`, and `prox <cmd>` runs a single command through `proxychains4 -f` using the same file.

## Known fish-vs-zsh gotchas

- `~/.cargo/env` is POSIX-only; fish uses `~/.cargo/env.fish` (rustup writes both).
- Proxy config now lives in `~/.config/proxychains.conf` (read by both `proxy` and `prox`). The old `~/set_proxy.sh` / `$http_proxy_server` mechanism was removed — if the config file is absent, `proxy` offers to write a template and `prox` writes one then aborts.
- NVM has no native fish support; it's provided by the `nvm.fish` plugin and does not see Node versions previously installed under `~/.nvm`.
