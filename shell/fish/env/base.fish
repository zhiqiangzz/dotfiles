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
# ~/set_proxy.sh is POSIX; source it through the `bass` plugin (runs it in bash
# and imports the resulting env into fish) so there's a single source of truth
# and no separate fish port to maintain. Requires the bass plugin + python3;
# skipped silently if either is unavailable (e.g. before fisher has bootstrapped).
if test -f "$HOME/set_proxy.sh"; and type -q bass; and type -q python3
    bass source "$HOME/set_proxy.sh"
end
