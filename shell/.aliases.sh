# alias

alias fd=fdfind
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
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset all_proxy http_proxy https_proxy'
