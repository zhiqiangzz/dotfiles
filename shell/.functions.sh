# efficient scrpit

case $(uname) in
Darwin) 
  function cbpwd(){
    local current_dir=$(pwd | sed "s|$HOME|~|g")
    echo $current_dir | pbcopy
  }
  function cbtxtfile() {
    cat $1 | pbcopy
  }
  ;;
Linux) ;;
esac

# llvm related func
function llvm-conf() {
  llvm-config --cxxflags --ldflags --system-libs --libs core
}

function genllrv() {
  input_file=$1
  output_file_ll="${1%.*}.ll"
  output_file_s="${1%.*}.s"

  clang++ $input_file --target=riscv64-unknown-elf -march=rv64g -emit-llvm -S -O0 \
  -fno-discard-value-names -Xclang -disable-O0-optnone -o $output_file_ll
  opt $output_file_ll -p=mem2reg -S -o $output_file_ll
}

function genllrv32() {
  input_file=$1
  output_file_ll="${1%.*}.ll"
  output_file_s="${1%.*}.s"

  clang++ $input_file --target=riscv32-unknown-elf -march=rv32i -emit-llvm -S -O0 \
  -fno-discard-value-names -Xclang -disable-O0-optnone -o $output_file_ll
  opt $output_file_ll -p=mem2reg -S -o $output_file_ll
}

# vscode
function killvscode() {
  case $(uname) in
  Darwin) ;;
  Linux)
    ps aux | grep .vscode-server | awk '{print $2}' | xargs kill
    ;;
  esac
}

# git
function stashAllFile() {
  git stash push -u $(git status --porcelain | awk '{print $2}' | rg -v 'gitignore')
}

# diff two directories
function dirDiff() {
  if [ $# -ne 2 ]; then
    echo "Usage: $0 directory1 directory2"
    exit 1
  fi

  dir1=$1
  dir2=$2

  if [ ! -d "$dir1" ] || [ ! -d "$dir2" ]; then
    echo "Both parameters should be directories."
    exit 1
  fi

  for file in "$dir1"/*; do
    filename=$(basename "$file")
    if [ -f "$dir2/$filename" ]; then
      if ! diff "$file" "$dir2/$filename" >/dev/null; then
        echo "Difference found in file: $filename"
      fi
    else
      # echo "No matching file for $filename in $dir2"
    fi
  done
}

# format json file
function jqq() {
  unformat=$1"unformat.json"
  mv $1 $unformat
  jq . $unformat >$1 2>&1
  rm -f $unformat
}

# compress and decompress
function compress7z() {
  if [ -z "$1" ]; then
    echo "Usage: $0 file to 7z"
    exit 1
  fi

  file="$1"
  7z a -mmt $file.7z $file
}

function compress_zip() {
  if [ -z "$1" ]; then
    echo "Usage: $0 file to zip"
    exit 1
  fi

  file="$1"
  zip -r $file.zip $file
}

function compress_targz() {
  if [ -z "$1" ]; then
    echo "Usage: $0 file to tar.gz"
    exit 1
  fi

  file="$1"
  tar -czvf $file.tar.gz $file
}

function decompress() {
  if [ -z "$1" ]; then
    echo "Usage: $0 file.7z/zip/tar/gz"
    exit 1
  fi
  # Get the file name and extension
  file="$1"
  extension="${file##*.}"

  # Choose the extraction method based on the file extension
  case "$extension" in
  "tar")
    echo "Extracting tar file..."
    tar -xvf "$file"
    ;;
  "gz")
    echo "Extracting gz file..."
    tar -xzvf "$file"
    ;;
  "bz2")
    echo "Extracting bz2 file..."
    tar -xjvf "$file"
    ;;
  "xz")
    echo "Extracting xz file..."
    tar -xJvf "$file"
    ;;
  "zip")
    echo "Extracting zip file..."
    unzip "$file"
    ;;
  "rar")
    echo "Extracting rar file..."
    unrar x "$file"
    ;;
  "7z")
    echo "Extracting 7z file..."
    7z x "$file"
    ;;
  *)
    echo "Unsupported file format: $extension"
    exit 1
    ;;
  esac
}

function inheritEnv() {
    sudo cat /proc/1/environ | tr '\0' '\n' \
  | xargs -I {} bash -c 'v=$(echo "{}" | cut -d= -f1); [ -z "${!v}" ] && echo "export {}"; true' \
  | source /dev/stdin
}

# proxy
function proxy() {
  case $(hostname) in
  ryukk-ubuntu101|"zhiqiangzs-MacBook-Pro.local")
    export https_proxy=${http_proxy_server:-http://127.0.0.1:7890} 
    export http_proxy=${http_proxy_server:-http://127.0.0.1:7890} 
    export all_proxy=${all_proxy_server:-socks5://127.0.0.1:7890}
    ;;
  *) 
    export https_proxy=${http_proxy_server:-http://127.0.0.1:7890} 
    export https_proxy=$http_proxy_server
    export http_proxy=$http_proxy_server
    export all_proxy=$all_proxy_server
    ;;
  esac
}

function unproxy() {
  unset all_proxy http_proxy https_proxy
}

function ippublic() {
  curl ipinfo.io
}
