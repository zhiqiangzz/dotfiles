# Helper vocabulary + cached OS/host identity. Must be sourced first.
# Fish equivalents of shell/zsh/lib/guards.zsh.

# Cached OS/host identity (exported once, branched on elsewhere).
if not set -q DOTFILES_OS
    switch (uname)
        case Darwin
            set -gx DOTFILES_OS Darwin
        case Linux
            set -gx DOTFILES_OS Linux
        case '*'
            set -gx DOTFILES_OS (uname)
    end
end

if not set -q DOTFILES_HOST
    # Short hostname (strip everything after the first dot), matching ${HOST%%.*}.
    set -gx DOTFILES_HOST (hostname | string split -f1 .)
end

# Source a file only when it exists.
function source_if_file
    test -n "$argv[1]"; and test -f "$argv[1]"; and source "$argv[1]"
end

# Return success when a command exists in PATH.
function has_cmd
    type -q -- $argv[1]
end

# Require one or more commands; on any missing, explain why the caller cannot run
# (one line per missing command) on stderr and return 1. Use at the top of a
# function as `require_cmds foo bar; or return 1` so the dependency is never
# silently swallowed.
function require_cmds
    set -l missing
    for c in $argv
        type -q -- $c; or set -a missing $c
    end
    test (count $missing) -eq 0; and return 0
    for c in $missing
        echo "required command not installed: '$c' — cannot run (install it first)" >&2
    end
    return 1
end

# Ask a yes/no question, but only when stdin is a TTY so scripts/cron never block
# on a prompt. Returns 0 on an affirmative reply; non-interactive (or non-yes)
# returns 1 without prompting. Callers should print any "how to fix" hint to
# stderr themselves — this only handles the interactive question.
function confirm
    isatty stdin; or return 1
    read -l -P "$argv[1] [y/N] " reply
    string match -qir '^y(es)?$' -- "$reply"
end

# Run a command string only when an executable exists.
function run_if_cmd
    if type -q -- $argv[1]
        eval $argv[2]
    end
end

# Source a POSIX/bash env file into fish via the `bass` plugin, but only when the
# file exists and bass (plus its python3 dependency) is available. Silent no-op
# otherwise. Use for sh-syntax env files that fish cannot source natively.
function bass_source_if_file
    test -f "$argv[1]"; or return
    type -q bass; and type -q python3; or return
    bass source "$argv[1]"
end

# Append directory to PATH if it exists (fish_add_path dedupes automatically).
function path_append_if_dir
    test -d "$argv[1]"; and fish_add_path -ga "$argv[1]"
end

# Prepend directory to PATH if it exists (fish_add_path dedupes automatically).
function path_prepend_if_dir
    test -d "$argv[1]"; and fish_add_path -gp "$argv[1]"
end

# Detect the effective egress country via public-IP geolocation. curl honors
# http_proxy, so this reflects the proxy exit (proxy up → its country; proxy off
# → the local country). No caching — each call probes live (2s timeout) so it
# always reflects the current proxy state. Echoes the 2-letter code and returns
# 0; returns 1 with no output on offline/timeout/no-curl.
function _dotfiles_ip_country
    has_cmd curl; or return 1
    set -l country (curl -fsS --max-time 2 https://ipinfo.io/country 2>/dev/null | string trim)
    test -n "$country"; or return 1
    echo "$country"
end

# Guard: succeed only when the egress country is known AND not in $argv.
# Fail-closed — an undeterminable country (offline/timeout/no-curl) also fails.
# Set DOTFILES_NO_COUNTRY_GUARD to bypass entirely (an escape hatch, since
# fail-closed can otherwise lock you out when offline). Use at the top of a
# wrapper as `require_country_not CN; or return 1`.
function require_country_not
    set -q DOTFILES_NO_COUNTRY_GUARD; and return 0
    set -l country (_dotfiles_ip_country)
    if test -z "$country"
        echo "[guard] cannot determine egress country; refusing to run (fail-closed). Set DOTFILES_NO_COUNTRY_GUARD=1 to override." >&2
        return 1
    end
    if contains -- $country $argv
        echo "[guard] egress country is $country; refusing to run here. Set DOTFILES_NO_COUNTRY_GUARD=1 to override." >&2
        return 1
    end
end
