#!/usr/bin/env bash
# vim: ft=bash

# open.sh - Open a file with mpv if it's larger than 10 MiB, otherwise use xdg-open

set -euo pipefail

file=${1:-}
shift

if [[ -z $file ]]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

if [[ ! -e $file ]]; then
    echo "Error: '$file' not found" >&2
    exit 1
fi

if size=$(stat --printf='%s' "$file" 2>/dev/null); then               # GNU coreutils
    :
elif size=$(stat -f '%z' "$file" 2>/dev/null); then                   # BSD/macOS
    :
else
    echo "Error: couldn't determine file size (incompatible 'stat')" >&2
    exit 1
fi

threshold=$((10 * 1024 * 1024))   # 10 MiB

if (( size > threshold )); then
    exec mpv "$file" "$@"
else
    exec "${EDITOR:-vim}" "$file" "$@"
fi
