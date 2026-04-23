#!/usr/bin/env zsh

export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export HF_ENDPOINT="https://hf-mirror.com"

path_append_if_dir "$HOME/.local/bin"
source_if_file "$HOME/.cargo/env"
source_if_file "$HOME/set_proxy.sh"
