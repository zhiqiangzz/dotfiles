# alias

function setup_aliases_if_exist() {
  local alias_name="$1"
  local alias_cmd="$2"

  local cmd_base
  cmd_base=$(echo "$alias_cmd" | awk '{print $1}')

  if command -v "$cmd_base" >/dev/null 2>&1; then
    alias "$alias_name"="$alias_cmd"
  fi
}

setup_aliases_if_exist ls eza
setup_aliases_if_exist clear "echo -e \"\033c\""

setup_aliases_if_exist ezsh "vim ~/.zshrc"
setup_aliases_if_exist szsh "source ~/.zshrc"

case $(uname) in
Darwin)
  setup_aliases_if_exist cat "bat -p"
  setup_aliases_if_exist iplocal "ipconfig getifaddr en0"
  ;;
Linux)
  setup_aliases_if_exist fd fdfind
  setup_aliases_if_exist iplocal "ifconfig enp5s0 | rg 'inet ' | awk '{ print \$2 }'"
  setup_aliases_if_exist cat "batcat -p"
  ;;
esac

setup_aliases_if_exist ippublic "curl ipinfo.io"

case $(hostname) in
Darwin) ;;
Linux) ;;
esac
