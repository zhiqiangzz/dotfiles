# Cross-platform environment / PATH (port of shell/zsh/env/base.zsh).

set -gx LANGUAGE en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Region mirrors (see CLAUDE.md "Mirrors / region note").
set -gx HF_ENDPOINT https://hf-mirror.com
set -gx RUSTUP_DIST_SERVER https://mirrors.ustc.edu.cn/rust-static
set -gx RUSTUP_UPDATE_ROOT https://mirrors.ustc.edu.cn/rust-static/rustup

path_append_if_dir "$HOME/.local/bin"

# Rust/cargo: use the fish variant. The POSIX ~/.cargo/env cannot be sourced
# by fish; rustup also writes ~/.cargo/env.fish.
source_if_file "$HOME/.cargo/env.fish"

# OS- then host-specific layers, most-general to most-specific. Chained here so
# config.fish only needs to source env/base.fish.
source_if_file "$DOTFILES_FISH_HOME/env/os/$DOTFILES_OS.fish"
source_if_file "$DOTFILES_FISH_HOME/env/host/$DOTFILES_HOST.fish"
