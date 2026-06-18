{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  # ● Bash(cd /home/rok/src/codeberg.org/aca/nix-config && nix eval --raw .#nixosConfigurations.home.config.programs.tmux.extraConfig 2>&1 | tail -20)
  #   ⎿  if "[[ ${SSH} =~ 256color ]]" 'set -g default-terminal screen-256color'
  #
  #      # if-shell '[ -n "$SSH_TTY" ]' 'set-hook -g pane-focus-out "run-shell \"tmux refresh-client -l\""'
  #      … +16 lines (ctrl+o to expand)
  #   ⎿  Shell cwd was reset to /home/rok/src/codeberg.org/aca/nix-config/pkgs/tmux
  #   ⎿  (timeout 2m)
  #
  # ● It evaluates successfully. The path resolves to /nix/store/...-tmuxplugin-tmux-remote-unstable/share/tmux-plugins/tmux-remote/remote.tmux. mkTmuxPlugin works correctly here.
  #
  # ✻ Sautéed for 42s
  #
  tmux-remote = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-remote";
    version = "unstable";
    src = ./tmux-remote;
  };
in
{
  environment.systemPackages = [
    pkgs.tmux-xpanes
  ];

  programs.tmux = {
    enable = true;
    # clock24 = true;
    extraConfig =
      builtins.readFile ./tmux.conf
      + ''
        run-shell ${tmux-remote}/share/tmux-plugins/tmux-remote/remote.tmux
      '';
  };
}
