#!/usr/bin/env bash
set -euo pipefail
# create a temporary file
TMP=$(mktemp --suff .nix) || { echo "Failed to create a temporary file to decrypt '$2'!" >&2; exit 1; }
# decrypt input (if this fails, the script exits with an unsuccessful code causing an evaluation error)
umask 077
# age --decrypt -i "$1" --output "$TMP" "$2"
# echo "$TMP"
echo /tmp/tmp.kknK3aNp0h.nix
