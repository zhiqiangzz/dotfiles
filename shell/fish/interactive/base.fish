# Stage 3 — interactive session setup (fish's .zshrc analog). Sourced only for
# interactive shells (gated in config.fish). Everything here may assume a TTY:
# tool inits that print or install prompt/keybinding hooks, prompt config,
# keybindings, greeting, and startup actions.
#
# Ordering matters and is deliberate:
#   1. os/$OS layer first — it extends PATH (e.g. Homebrew), so later command
#      probes see those tools.
#   2. general tool inits (fzf).
#   3. zoxide LAST — it installs a prompt/cd hook and must observe the final
#      state (same hook-ordering constraint as the old zsh setup).
#   4. startup actions — run after stage 2 defined all functions.
#
# There is intentionally no separate "login" layer: fish has no login/non-login
# config split, so the old login/base.fish (fzf, nvm note) folds in here.

# OS-specific interactive layer (base → os, mirroring env/). Chained here so this
# file owns the interactive sublayers; Linux has none, so source_if_file no-ops.
source_if_file "$DOTFILES_FISH_HOME/interactive/os/$DOTFILES_OS.fish"

# fzf keybindings + completions.
run_if_cmd fzf 'fzf --fish | source'

set -gx FZF_CTRL_R_OPTS "--height 40% --reverse --border --preview 'echo {}' --preview-window=up:3:wrap"

# NVM: zsh lazy-loaded ~/.nvm/nvm.sh via stub functions. Fish has no native nvm,
# so node/npm come from the nvm.fish plugin (see fish_plugins). Note: nvm.fish
# manages its own install dir and will not see Node versions previously installed
# under ~/.nvm — reinstall them with `nvm install <version>`, or switch to fnm.

# zoxide must init LAST (hook-ordering constraint).
run_if_cmd zoxide 'zoxide init --cmd cd fish | source'

# --- startup actions (stage 2 functions are all defined by now) ---
# Apply proxy env only when a config exists, so a missing config doesn't trigger
# the interactive "generate template?" prompt on every shell start.
test -f "$HOME/.config/proxychains.conf"; and proxy
# Load a .env in the directory the shell starts in (the PWD handler only fires on
# subsequent cd).
_dotenv_autoload
