# Interactive environment + tool inits (port of shell/zsh/interactive/base.zsh).

switch $DOTFILES_OS
    case Darwin
        if test -x /opt/homebrew/bin/brew
            /opt/homebrew/bin/brew shellenv | source
        end
        source_if_file "$HOME/.orbstack/shell/init2.fish"
    case Linux
end

set -gx FZF_CTRL_R_OPTS "--height 40% --reverse --border --preview 'echo {}' --preview-window=up:3:wrap"

# Plugin manager (fisher) — bootstrap if missing, then it manages the plugins
# listed in ~/.config/fish/fish_plugins. Mirrors the old Zim self-install.
if not functions -q fisher
    if type -q curl
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        and fisher install jorgebucaran/fisher
    end
end

# zoxide must init LAST (same hook-ordering constraint as the zsh setup).
if type -q zoxide
    zoxide init --cmd cd fish | source
end
