#!/usr/bin/env zsh

function llvm_conf() {
  require_cmds llvm-config || return 1
  llvm-config --cxxflags --ldflags --system-libs --libs core
}

function genllrv() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: genllrv <input_file>"
    return 1
  fi
  require_cmds clang++ opt || return 1
  local input_file="$1"
  local output_file_ll="${1%.*}.ll"
  clang++ "$input_file" --target=riscv64-unknown-elf -march=rv64g -emit-llvm -S -O0 \
    -fno-discard-value-names -Xclang -disable-O0-optnone -o "$output_file_ll" &&
    opt "$output_file_ll" -p=mem2reg -S -o "$output_file_ll"
}

function genllrv32() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: genllrv32 <input_file>"
    return 1
  fi
  require_cmds clang++ opt || return 1
  local input_file="$1"
  local output_file_ll="${1%.*}.ll"
  clang++ "$input_file" --target=riscv32-unknown-elf -march=rv32i -emit-llvm -S -O0 \
    -fno-discard-value-names -Xclang -disable-O0-optnone -o "$output_file_ll" &&
    opt "$output_file_ll" -p=mem2reg -S -o "$output_file_ll"
}
