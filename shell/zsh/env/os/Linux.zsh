#!/usr/bin/env zsh

path_prepend_if_dir "/usr/local/cuda/bin"
if [[ -d "/usr/local/cuda/lib64" ]]; then
  export LD_LIBRARY_PATH="/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

if [[ -d "/usr/lib/jvm/java-17-openjdk" ]]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
fi
export SBT_OPTS="-Dsbt.override.build.repos=true"
