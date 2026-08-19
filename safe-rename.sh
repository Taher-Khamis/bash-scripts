#!/bin/bash

# Renames files in a directory to safe forms: replaces spaces
# with underscores, removes a leading hyphen, deletes single
# quotes, and replaces newlines in filenames with underscores.
#
# Dry run is the default. Nothing is renamed unless --apply
# is given. Files whose target name already exists are skipped
# with a warning rather than overwritten. Directories are
# skipped entirely.
#
# Usage: ./safe-rename.sh <directory> [--apply|--dry-run]
#
# Exit codes: 0 success, 1 bad arguments or not a directory
#
# Known limitation: operates on the top level only, skips
# hidden files, removes only one leading hyphen, and handles
# only the characters listed above.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Error: expected 1 or 2 arguments, got $#" >&2
  exit 1
fi

if [[ ! -d "$1" ]]; then
  echo "not a directory: $1" >&2
  exit 1
fi

dir=$1
mode=${2:-}

if [[ -n "$mode" && "$mode" != "--apply" && "$mode" != "--dry-run" ]]; then
  echo "Error: unknown option: $mode" >&2
  echo "Usage: $0 <directory> [--apply|--dry-run]" >&2
  exit 1
fi

for f in "$dir"/*; do
  [[ -f "$f" ]] || continue
  name=$(basename "$f")
  newname="${name// /_}"
  newname="${newname#-}"
  newname="${newname//\'/}"
  newname="${newname//$'\n'/_}"

  if [[ "$name" == "$newname" ]]; then
    continue
  fi

  if [[ -e "$dir/$newname" ]]; then
    echo "Warning, the file $newname already exist" >&2
    continue
  fi

  if [[ "$mode" == "--apply" ]]; then
    mv "$f" "$dir/$newname"
    echo "renamed: $name -> $newname"
  else
    echo "$name -> $newname"
  fi
done
