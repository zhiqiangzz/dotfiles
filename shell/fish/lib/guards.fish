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

# Require one or more commands; report all missing on stderr and return 1.
function require_cmds
    set -l missing
    for c in $argv
        type -q -- $c; or set -a missing $c
    end
    if test (count $missing) -gt 0
        echo "missing commands: $missing" >&2
        return 1
    end
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
