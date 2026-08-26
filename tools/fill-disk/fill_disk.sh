#!/usr/bin/env bash
#
# fill_disk.sh - create a given number of files of a given size in a given directory
#
# Usage:
#   ./fill_disk.sh -d /path/to/dir -n 100 -s 10M [-p prefix]
#
# Options:
#   -d  target directory (created if missing)
#   -n  number of files to create
#   -s  size per file (e.g. 1K, 10M, 2G) - passed to `dd`/`fallocate` style suffixes
#   -p  filename prefix (default: "file")
#   -r  fill with random data instead of zeros (slower, but not sparse/compressible)
#   -h  show this help

set -euo pipefail

DIR=""
COUNT=""
SIZE=""
PREFIX="file"
RANDOM_DATA=0

usage() {
  grep '^#' "$0" | sed 's/^#//' | sed '1d'
  exit 1
}

while getopts ":d:n:s:p:rh" opt; do
  case "$opt" in
    d) DIR="$OPTARG" ;;
    n) COUNT="$OPTARG" ;;
    s) SIZE="$OPTARG" ;;
    p) PREFIX="$OPTARG" ;;
    r) RANDOM_DATA=1 ;;
    h) usage ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument" >&2; usage ;;
  esac
done

if [[ -z "$DIR" || -z "$COUNT" || -z "$SIZE" ]]; then
  echo "Error: -d, -n and -s are all required." >&2
  usage
fi

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [[ "$COUNT" -le 0 ]]; then
  echo "Error: -n must be a positive integer." >&2
  exit 1
fi

mkdir -p "$DIR"

echo "Target directory : $DIR"
echo "File count       : $COUNT"
echo "File size        : $SIZE"
echo "Data type        : $([[ $RANDOM_DATA -eq 1 ]] && echo random || echo zeros)"
echo

for ((i = 1; i <= COUNT; i++)); do
  FILE="$DIR/${PREFIX}_$(printf '%05d' "$i")"

  if command -v fallocate >/dev/null 2>&1 && [[ "$RANDOM_DATA" -eq 0 ]]; then
    # fast path: instantly allocate a sparse/preallocated file of exact size
    fallocate -l "$SIZE" "$FILE"
  else
    # portable path: works for random data or when fallocate is unavailable
    SRC=$([[ "$RANDOM_DATA" -eq 1 ]] && echo /dev/urandom || echo /dev/zero)
    dd if="$SRC" of="$FILE" bs="$SIZE" count=1 status=none
  fi

  printf "\rCreated %d/%d files" "$i" "$COUNT"
done

echo
echo "Done. Total size written: $(du -sh "$DIR" | cut -f1)"
