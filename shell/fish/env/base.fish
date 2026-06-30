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

# Proxy server vars ($http_proxy_server / $all_proxy_server), read by `proxy`.
# The original ~/set_proxy.sh is POSIX and cannot be sourced by fish; use the
# fish port ~/set_proxy.fish instead (both files live outside this repo).
source_if_file "$HOME/set_proxy.fish"
