# Interactive login setup (port of shell/zsh/login/base.zsh).

# fzf keybindings + completions.
if type -q fzf
    fzf --fish | source
end

# NVM: zsh lazy-loaded ~/.nvm/nvm.sh via stub functions. Fish has no native
# nvm, so node/npm are provided by the nvm.fish plugin (see fish_plugins,
# bootstrapped by interactive/base.fish). Note: nvm.fish manages its own
# install dir and will not see Node versions previously installed under
# ~/.nvm — reinstall them with `nvm install <version>`, or switch to fnm.
