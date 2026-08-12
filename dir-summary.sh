#!/bin/bash

# Prints a summary of a directory: file count, total size,
# and the three largest files, searching recursively.
#
# Total size is disk usage as reported by du, which reflects
# space consumed on disk rather than summed file content.
#
# Known limitation: exits early if it encounters a directory
# it cannot read.
#
# Usage: ./dir-summary.sh <directory>
# Exit codes: 0 success, 1 bad or missing argument

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Error: expected 1 argument, got $#" >&2
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "not a directory: $1" >&2
    exit 1
fi

count=$(find "$1" -type f | wc -l)
echo "The file count is: $count"

size=$(du -sh "$1" | cut -f 1)
echo "The total size of this directory is: $size"

largest_files=$(find "$1" -type f -print0 | xargs -0 -r du -h | sort -rh | head -n 3)
if [[ -z "$largest_files" ]]; then
  echo "No files found."
else
  echo "The three largest files are: "
  echo "$largest_files"
fi