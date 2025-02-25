# alias

alias fd=fdfind
alias cat="batcat -p"
alias ls=eza
alias clear="echo -e \"\033c\""

alias ezsh="vim ~/.zshrc"
alias szsh="source ~/.zshrc"

case $(uname) in
Darwin) ;;
Linux)
  alias iplocal="ifconfig enp5s0 | rg 'inet ' | awk '{ print \$2 }'"
  ;;
esac

alias ippublic='curl ipinfo.io'

