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
  ;;
esac
