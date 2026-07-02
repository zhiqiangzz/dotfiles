# Stage 3 (interactive), macOS layer — sourced by interactive/base.fish only on
# Darwin. OS-specific interactive tool inits; keep general inits in base.fish.

# Homebrew: export its shellenv (PATH, MANPATH, etc.) when the brew binary is
# present. Runs before the general inits in base.fish so later `type -q` checks
# see Homebrew-installed tools.
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

# OrbStack shell integration (docker/orb helpers), if installed.
source_if_file "$HOME/.orbstack/shell/init2.fish"
