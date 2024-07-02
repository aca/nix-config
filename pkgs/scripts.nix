{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [
    (
      pkgs.writeShellScriptBin "svc" ''
        sudo systemctl "$@"
      ''
    )
    (
      pkgs.writeShellScriptBin "svcu" ''
        systemctl --user "$@"
      ''
    )
    (
      pkgs.writeShellScriptBin "f1" ''
        awk "$@" '{print $1}'
      ''
    )
    (
      pkgs.writeShellScriptBin "f2" ''
        awk "$@" '{print $2}'
      ''
    )
    (
      pkgs.writeShellScriptBin "f3" ''
        awk "$@" '{print $3}'
      ''
    )

    # git quick
    (
      pkgs.writeShellScriptBin "ga" ''
        set -x
        git add -v -A
      ''
    )
    (
      pkgs.writeShellScriptBin "gc" ''
        set -x
        git commit --allow-empty-message -m ""
      ''
    )
    (
      pkgs.writeShellScriptBin "gac" ''
        set -x
        git add -v -A
        git commit --allow-empty-message -m ""
      ''
    )
    (
      pkgs.writeShellScriptBin "gacp" ''
        set -x
        git add -v -A
        git commit --allow-empty-message -m ""
        git push
      ''
    )

    (
      pkgs.writeShellScriptBin "fzf.src" ''
        set -euo pipefail
        if [ ! -f ~/.cache/src.index ]; then
          echo "not exist"
          src.updateindex
        fi

        d=$(cat ~/.cache/src.index | fzf)

        if [ -z "$d" ]; then
          echo $PWD
        else
          echo ~/src/$d
        fi
        src.updateindex &
      ''
    )

    (
      pkgs.writeShellScriptBin "src.updateindex" ''
        set -euo pipefail
        mkdir -p ~/.cache
        tmpf=$(mktemp)
        tmpf2=$(mktemp)

        fd --base-directory ~/src --strip-cwd-prefix --type d --follow --max-depth 6 > "$tmpf"

        # include
        # echo "git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next" >> "$tmpf"

        # exclude
        cat $tmpf | grep -v 'hito' > $tmpf2; cp $tmpf2 $tmpf
        cat $tmpf | grep -v 'newt' > $tmpf2; cp $tmpf2 $tmpf

        mv -f "$tmpf" ~/.cache/src.index
      ''
    )

    (
      pkgs.writeShellScriptBin "z" ''
        set -euo pipefail
        # cd ~/src/zk."$(hostname -s)"
        cd ~/src/zk

        if [ "$#" -eq 0 ]; then
          files=$(fd --type f . | fzf --preview 'bat {}' --preview-window='right,70%')
          if [ "$files" = "" ]; then
            exit 0
          fi
          $EDITOR -o $files
        else
          $EDITOR "$(date '+%Y-%m-%d %H:%M:%S') $(echo "$@" | sed 's/ /-/g').md"
        fi
      ''
    )

    (pkgs.writeShellScriptBin "p" ''mpv --playlist=- --msg-level=file=no "$@" '')
    (pkgs.writeShellScriptBin "fdf" ''fd --type f "$@" '')
    (pkgs.writeShellScriptBin "fdd" ''fd --type d "$@" '')

    (
      pkgs.writeTextFile {
        name = "elvish-test2";
        text = ''
          #!${pkgs.elvish}/bin/elvish
          echo 3
        '';
        executable = true;
        destination = "/bin/my-file2";
      }
    )
    (
      if pkgs.stdenv.isDarwin
      then
        pkgs.writeShellScriptBin "vol" ''
        ''
      else
        pkgs.writeShellScriptBin "vol" ''
          set -euo pipefail
          pactl list sinks short | awk '{print $1}' | xargs -I{} pactl set-sink-volume {} "$1%"
        ''
    )
  ];
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
#
# pkgs.writeTextFile {
#   name = "elvish-test2";
#   text = ''
#   #!${pkgs.elvish}/bin/elvish
#   use math
#   osascript -e "set Volume "(math:round (/ $args[0] 10))
#   ''
# }

