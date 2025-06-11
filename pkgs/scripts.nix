{
  config,
  pkgs,
  lib,
  inputs,
  modules,
  ...
}: let
  hostname = config.networking.hostName;
  binscripts =
    builtins.mapAttrs (name: text: builtins.readFile ((builtins.toString ./.) + "/scripts/${name}"))
    (
      lib.filterAttrs (
        key: value:
          value
          == "regular"
          && key != "tsconfig.json"
          && key != "bun.lockb"
          && key != "package.json"
          && key != ".gitignore"
      ) (builtins.readDir ./scripts)
    );
in {
  # imports = [
  #   ./scripts__git.nix
  # ];
  environment.systemPackages =
    [
      pkgs.rsync
      (pkgs.writeShellScriptBin "bak" ''mv -v -n "$1" "$1"$(date +%y%m%dT%H%M%S)'')
      (pkgs.writeShellScriptBin "nvimlog" ''tail -f ~/.cache/nvim/plenary.log'')
      (pkgs.writeShellScriptBin "svc" ''sudo systemctl "$@" '')
      (pkgs.writeShellScriptBin "svcu" ''systemctl --user "$@" '')
      (
        # logdir="$HOME/src/zk/log/${(config.networking.hostName)}"
        pkgs.writeShellScriptBin "zl" ''
          set -euo pipefail
          logdir="$HOME/src/zk/log/$USER"
          cd "$logdir" || mkdir -p "$logdir" && cd "$logdir"
          $EDITOR "$logdir/$(date '+%Y-%m-%d').md"
        ''
      )

      # (pkgs.writeShellScriptBin "rm" ''
      #   ${pkgs.rmtrash}/bin/rmtrash "$@"
      # '')

      (pkgs.writeShellScriptBin "whichcat" ''
        ${pkgs.bat}/bin/bat $(which "$1")
      '')
      (pkgs.writeShellScriptBin "gogen" ''go generate ./...'')

      (pkgs.writeShellScriptBin "git.rmhistory" ''
        set -x
        set -euxo pipefail
        branch_cur=$(git rev-parse --abbrev-ref HEAD)
        branch="rmhistory"
        git branch -D $branch || true
        git checkout --orphan $branch
        git add -A
        git commit --allow-empty-message -m ""
        git branch -D $branch_cur
        git branch -m $branch_cur
        git gc --aggressive --prune=all
      '')

      # git quick
      (pkgs.writeShellScriptBin "ga" ''
        set -x
        git add -v -A
      '')
      (pkgs.writeShellScriptBin "gc" ''
        set -x
        git commit --allow-empty-message -m ""
      '')
      (pkgs.writeShellScriptBin "gac" ''
        set -x
        git add -v -A
        git commit --allow-empty-message -m ""
      '')
      (pkgs.writeShellScriptBin "gacp" ''
        set -x
        git add -v -A
        git commit --allow-empty-message -m ""
        git push
      '')
      (pkgs.writeShellScriptBin "gpr" ''
        git pull --rebase "$@"
      '')
      (pkgs.writeShellScriptBin "gst" ''git stats "$@"'')

      (pkgs.writeShellScriptBin "extract" ''
        for e in "$@"
        do
          ${pkgs.atool}/bin/aunpack "$e"
        done
      '')

      (pkgs.writeShellScriptBin "tar.gz9" ''
        for e in "$@"
        do
          tar c "$e" | gzip --best > "$e.tar.gz"
        done
      '')

      (pkgs.writeShellScriptBin "osc7" ''
        printf "\e]7;$1\e\\"
      '')

      (pkgs.writeShellScriptBin "nix.hash" ''
        echo 'nix hash to-sri --type sha256 $(nix-prefetch-url https://xxx.zip)'
        nix hash to-sri --type sha256 $(nix-prefetch-url ''$1)
      '')

      (pkgs.writeShellScriptBin "fzf.src" ''
        set -euo pipefail
        if [ ! -f ~/.cache/src.index ]; then
          src.updateindex
        fi

        d=$(cat ~/.cache/src.index | ${pkgs.fzf}/bin/fzf)

        if [ -z "$d" ]; then
          echo $PWD
        else
          echo ~/src/$d
        fi
        # rund src.updateindex
      '')

      (pkgs.writeShellScriptBin "yt-dlp" ''
        ${pkgs.uv}/bin/uvx yt-dlp@latest "$@"
      '')

      (pkgs.writeShellScriptBin "p" ''mpv --playlist=- --msg-level=file=no "$@" '')
      (pkgs.writeShellScriptBin "sp" ''shuf | p "$@"'')
      # (pkgs.writeShellScriptBin "systemd-run" ''sudo systemd-run "--working-directory=$(pwd)"'')

      (pkgs.writeShellScriptBin "fda" ''${pkgs.fd}/bin/fd --hidden --no-ignore "$@"'')
      (pkgs.writeShellScriptBin "fdf" ''${pkgs.fd}/bin/fd --type f --hidden "$@"'')
      (pkgs.writeShellScriptBin "fdfa" ''${pkgs.fd}/bin/fd --type f --hidden --no-ignore "$@"'')
      (pkgs.writeShellScriptBin "fdd" ''${pkgs.fd}/bin/fd --type d --no-ignore --hidden "$@"'')
      (pkgs.writeShellScriptBin "ff" ''${pkgs.fd}/bin/fd -0 --type f --hidden | ${pkgs.fzf}/bin/fzf --read0 -m --ansi --preview "${pkgs.bat}/bin/bat --color=always --style=header,grid --line-range :250 -- {}"'')
      (pkgs.writeShellScriptBin "mv.flat" ''${pkgs.fd}/bin/fd --type f -x mv -v -n -- {} .'')

      # (pkgs.writeShellScriptBin "rgf" ''${pkgs.ripgrep}/bin/rg --files-with-matches "$@"'')

      # https://stackoverflow.com/questions/31437198/what-is-the-most-reliable-command-to-find-actual-size-of-a-file-linux
      # (pkgs.writeShellScriptBin "sizeof" ''
      #   set -euo pipefail
      #   if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      #       stat -cL "%s" "$1"
      #   else
      #       stat -fL "%z" "$1"
      #   fi
      # '')

      # tmux
      (pkgs.writeShellScriptBin "t" ''${pkgs.tmux}/bin/tmux new -s main || tmux attach -t main'')
      (pkgs.writeShellScriptBin "tk" ''${pkgs.tmux}/bin/tmux kill-session -t main'')
      (pkgs.writeShellScriptBin "tkk" ''${pkgs.tmux}/bin/tmux kill-server'')
      (pkgs.writeShellScriptBin "td" ''${pkgs.tmux}/bin/tmux detach'')

      # pueue
      (pkgs.writeShellScriptBin "pus" ''pueue status'')

      (pkgs.writeShellScriptBin "jqr" ''${pkgs.jq}/bin/jq -r "$@"'')

      (pkgs.writeShellScriptBin "rm.empty" ''${pkgs.fd}/bin/fd --type empty -x rm -rfv -- '')
      # (pkgs.writeShellScriptBin "rm.small.10m" ''${pkgs.fd}/bin/fd --type file --size -10m -x ${pkgs.gtrash}/bin/gtrash put -v --'')
      (pkgs.writeShellScriptBin "rm.small.100m" ''${pkgs.fd}/bin/fd --type file --size -100m -x rm -v --'')

      (pkgs.writeTextFile {
        name = "elvish-test2";
        text = ''
          #!${pkgs.elvish}/bin/elvish
          echo 3
        '';
        executable = true;
        destination = "/bin/my-file2";
      })

      (pkgs.writeTextFile {
        name = "work.antisleep";
        text = ''
          #!/usr/bin/env -S ${pkgs.bun}/bin/bun run
          import robot from "@hurdlegroup/robotjs";

          function sleep(ms) { Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms); }
          while (true) {
          robot.keyTap('tab', 'command');
          robot.keyTap('enter');
          sleep(5000)
          robot.moveMouse(1115, 483);
          robot.mouseClick();
          }
        '';
        executable = true;
        destination = "/bin/work.antisleep";
      })

      (
        if pkgs.stdenv.isLinux
        then
          pkgs.writeShellScriptBin "ci" ''
            # if [ "$SSH_TTY" != "" ]; then
            #     yank
            # fi

            # if pgrep copyq 1>/dev/null 2>/dev/null; then
            #     copyq copy - 1>/dev/null 2>/dev/null

            if [ "$WAYLAND_DISPLAY" = "" ]; then
                # timeout 5s xsel --clipboard --input
                xsel --clipboard --input
            else
                wl-copy
            fi
          ''
        else pkgs.writeShellScriptBin "ci" ''pbcopy''
      )

      (
        if pkgs.stdenv.isLinux
        then pkgs.writeShellScriptBin "pbcopy" "ci"
        else pkgs.writeShellScriptBin "pbcopy.darwin" "ci"
      )

      (
        if pkgs.stdenv.isLinux
        then
          pkgs.writeShellScriptBin "co" ''
            # if pgrep copyq 1>/dev/null 2>/dev/null; then
            #     copyq read 0
            if [ "$WAYLAND_DISPLAY" = "" ]; then
                xsel --clipboard --output
            else
                wl-paste --no-newline
            fi
          ''
        else pkgs.writeShellScriptBin "co" ''pbpaste''
      )

      (
        if pkgs.stdenv.isLinux
        then pkgs.writeShellScriptBin "pbpaste" ''co''
        else pkgs.writeShellScriptBin "pbpaste.darwin" ''ci''
      )

      (
        if pkgs.stdenv.isDarwin
        then
          pkgs.writeShellScriptBin "vol" ''
            ${pkgs.elvish}/bin/elvish -c 'use math; osascript -e "set Volume "(math:round (/ $args[0] 10))'
            # sudo osascript -e "set Volume "(math:round (/ $args[0] 10))
          ''
        else
          pkgs.writeShellScriptBin "vol" ''
            set -euo pipefail
            pactl list sinks short | awk '{print $1}' | xargs -I{} pactl set-sink-volume {} "$1%"
          ''
      )

      (pkgs.writeShellScriptBin "cppath" ''
        test "$#" -eq 0 \
            && pwd | pbcopy \
            || realpath "$1" | tr -d '\n' | pbcopy
        pbpaste
      '')

      (pkgs.writeShellScriptBin "vvim" ''
        cd ~/src/github.com/aca/dotfiles
        nvim .config/nvim/init.lua
      '')

      (pkgs.writeShellScriptBin "vif" ''
        ${pkgs.fd}/bin/fd --type f | sort -n | ${pkgs.moreutils}/bin/vidir -
      '')
      (pkgs.writeShellScriptBin "vifile" ''
        ${pkgs.fd}/bin/fd --type f | sort -n | ${pkgs.moreutils}/bin/vidir -
      '')

      (pkgs.writeShellScriptBin "audio-device-switch" ''
        set -euxo pipefail

        sink=$(pactl list short sinks |awk '{print $2}' | fzf)
        pactl set-default-sink $sink

        for i in $(pactl list short sink-inputs | awk '{print $1}')
        do
            pactl move-sink-input $i $sink
        done
      '')
      # (pkgs.writeShellScriptBin "scratch" (builtins.readFile ./scripts/scratch))

      # (pkgs.writeShellScriptBin "vbin" (builtins.readFile ./scripts/vbin))
      # (builtins.concatMap (name: builtins.readFile ("scripts/" + name)) (builtins.readDir ./scripts))
      # (builtins.mapAttrs (name: text: pkgs.writeShellScriptBin name text) (builtins.readDir ./scripts))
    ]
    ++ (map (
      name: (pkgs.writeTextFile {
        name = name;
        text = binscripts.${name};
        executable = true;
        destination = "/bin/${name}";
      })
    ) (builtins.attrNames binscripts));

  # (
  #   pkgs.writeTextFile {
  #     name = "elvish-test2";
  #     text = ''
  #       #!${pkgs.elvish}/bin/elvish
  #       echo 3
  #     '';
  #     executable = true;
  #     destination = "/bin/my-file2";
  #   }
  # )
}
# name = "vol";
# text = ''
# #!${pkgs.elvish}/bin/elvish
# use math
# # pactl set-sink-volume @DEFAULT_SINK@ $args[0]"%"
# for i [(pactl list sinks short | awk '{print $1}' | from-lines)] {
#   nop ?(pactl set-sink-volume $i $args[0]'%')
# }
# ''

