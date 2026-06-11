#!/usr/bin/env bash
# Move all "mp4" windows to WS 9 and tile 2×2

set -x

for pid in $(pgrep -f mpv); do
  con=$(swaymsg -t get_tree \
    | jq -r --arg pid "$pid" '
        .. 
        | select(.pid? == ($pid | tonumber)) 
        | .id
      ')
    echo $con
  if [[ -n "$con" ]]; then
    swaymsg "[con_id=$con] move workspace number 3"
  fi
done

swaymsg workspace number 3
swaymsg "split vertical; focus left; split horizontal; focus right; split horizontal"
