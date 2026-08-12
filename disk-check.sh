#!/bin/bash

# Checks disk usage of the filesystem holding the given path
# against warning and critical thresholds.
#
# Usage: ./disk-check.sh <path> <warning%> <critical%>
#
# Exit codes: 0 below warning, 1 at or above warning,
#             2 at or above critical, 3 bad arguments
#
# Known limitation: thresholds are not validated as numbers,
# and no check is made that warning is lower than critical.
# Non-numeric input causes the script to fail rather than
# produce a wrong answer.

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Error: expected 3 arguments, got $#" >&2
    exit 3 
fi

usage=$(df -Ph "$1" | awk '{print $5}' | tail -n 1 | tr -d '%')
warning=$2
critical=$3

if [[ $usage -ge $critical ]]; then
    echo "Critical threshold exceeded, current disk usage is: $usage%"
    exit 2
elif [[ $usage -ge $warning ]]; then
    echo "Warning threshold exceeded, current disk usage is: $usage%"
    exit 1
else
    echo "System disk usage is: $usage%"
    exit 0
fi
