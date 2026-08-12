#!/bin/bash

# Renames files in a directory to safe forms: replaces spaces
# with underscores, collapses repeated underscores, removes a
# leading hyphen, deletes single quotes, and replaces newlines
# in filenames with underscores.
#
# Dry run is the default. Nothing is renamed unless --apply
# is given. Files whose target name already exists are skipped
# with a warning rather than overwritten.
#
# Usage: ./safe-rename.sh <directory> [--apply]
#
# Exit codes: 0 success, 1 bad arguments or not a directory
#
# Known limitation: operates on the top level only, and does
# not handle every problematic character, only the ones above.

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

for f in "$dir"/*; do
    name=$(basename "$f")
    newname="${name// /_}"
    newname="${newname#-}"
    newname=$(echo "$newname" | tr -s '_')
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