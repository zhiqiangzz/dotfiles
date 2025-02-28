# alias

alias ls=eza
alias clear="echo -e \"\033c\""

alias ezsh="vim ~/.zshrc"
alias szsh="source ~/.zshrc"

case $(uname) in
Darwin) 
  alias cat="bat -p"
  alias iplocal="ipconfig getifaddr en0"
  ;;
Linux)
  alias fd=fdfind
  alias iplocal="ifconfig enp5s0 | rg 'inet ' | awk '{ print \$2 }'"
  alias cat="batcat -p"
  ;;
esac

alias ippublic='curl ipinfo.io'

case $(hostname) in
Darwin) ;;
Linux)
  ;;
esac