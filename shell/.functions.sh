# efficient scrpit

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

function inheritEnv(){
    sudo cat /proc/1/environ | tr '\0' '\n' \
  | xargs -I {} bash -c 'v=$(echo "{}" | cut -d= -f1); [ -z "${!v}" ] && echo "export {}"; true' \
  | source /dev/stdin
}