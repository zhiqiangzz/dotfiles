# Command wrappers guarded by egress country (see require_country_not in
# lib/guards.fish). A fish function only shadows the BARE command name — path
# invocations (./claude, ~/.local/bin/claude, /abs/path/claude) bypass function
# resolution and exec the file directly, and no shell hook can prevent that. So
# these wrappers cover the bare-name case by design; path invocations are not
# guarded. Set DOTFILES_NO_COUNTRY_GUARD=1 to disable the guard.

# Refuse to launch Claude Code from a CN egress (fail-closed). `command` skips
# this function, so there is no recursion.
function claude
    require_country_not CN; or return 1
    command claude $argv
end
