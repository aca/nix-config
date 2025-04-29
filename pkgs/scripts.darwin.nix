{
  config,
  pkgs,
  lib,
  inputs,
  modules,
  ...
}: let
  hostname = config.networking.hostName;
in {
  # imports = [
  #   ./scripts__git.nix
  # ];
  environment.systempackages =
    [
      (pkgs.writeShellScriptBin "yabai_kill_last" ''
#!/usr/bin/env bash
window_pid=$(/run/current-system/sw/bin/yabai -m query --windows --window | jq -r '.pid') 
count_pid=$(/run/current-system/sw/bin/yabai -m query --windows | /run/current-system/sw/bin/jq "[.[] | select(.pid == '$window_pid')] | length")
if [ "$count_pid" -gt 1 ]; then
	/run/current-system/sw/bin/yabai -m window --close
else
	/run/current-system/sw/bin/kill "$window_pid"
fi
      '')
    ];
}
