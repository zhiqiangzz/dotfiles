case $(hostname) in
ryukk-ubuntu101)
  export PATH="$PATH:/home/ryukk/.cache/scalacli/local-repo/bin/scala-cli"

  # >>> coursier install directory >>>
  export PATH="$PATH:/home/ryukk/.local/share/coursier/bin"
  # <<< coursier install directory <<<
  ;;
*) ;;
esac

case $(uname) in
Linux) ;;
Darwin)
  eval "$(/opt/homebrew/bin/brew shellenv)"
  # Added by OrbStack: command-line tools and integration
  # This won't be added again if you remove it.
  [[ ! -f ~/.orbstack/shell/init.zsh ]] || source ~/.orbstack/shell/init.zsh 2>/dev/null || :
  ;;
esac
