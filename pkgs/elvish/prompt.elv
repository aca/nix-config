# stty -ixon # https://github.com/elves/elvish/issues/1488

use str
use platform
# prompt {{{
# vi mode binding https://github.com/elves/elvish/issues/971
# set edit:rprompt-persistent = $true

var user = [&$true="" &$false=$E:USER"@"][(eq $E:USER rok)]
# var hostname = [&$true="nix" &$false=(platform:hostname)][(eq $E:HOST "txxx-nix")]
var hostname = (platform:hostname)

set edit:rprompt = {
  if (has-env IN_NIX_SHELL) {
    styled 'nix-shell | ' '#3e3e3e'
  }
  try {
    var branch = (str:trim-space (e:git rev-parse --abbrev-ref HEAD 2>/dev/null))
    styled $branch '#3e3e3e'
  } catch _ { }
}
set edit:-prompt-eagerness = 5
set edit:prompt-stale-threshold = 0.5

set edit:prompt = {
  styled (e:date '+%H:%M')" " '#3e3e3e';
  styled [&$true=$user$hostname" " &$false=""][(has-env SSH_CONNECTION)] yellow;
  styled '| ' red;
}

var short-addr = {
    var arr = [(str:split '/' (tilde-abbr $pwd))]
    if (eq (count $arr) (num 1)) {
        put $arr[0]
    } else {
        all $arr[0..-1] | each { |x| 
            if (not-eq $x '') {
                put $x[0] 
            } else {
                put $x
            }
        } | str:join '/' [(all) $arr[-1]]
    }
}

      # 111 -set edit:before-readline = [ $@edit:before-readline  { printf "\e]7;"$pwd"\e\\" } ]
      # 111 +set edit:before-readline = [ $@edit:before-readline  { printf "\e]7;file://%s%s\e\\" (platform:hostname) $pwd } ]

set edit:after-command = [
  {|m|
    # https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md


    printf "\033]133;A;cl=m;aid=%s\007" $pid
    # pprint $m
    if (< $m[duration] 10) {
      nop
    } else {
      if (has-env TMUX) {
        if (str:has-prefix $m[src][code] "vim") {
          nop
        } else {
          # tmux display-message -d 999999 -l $m[src][code]
          # tmux display-message -d 999999 -l $m[src][code]
        }
      }
      echo (styled (printf "« took: %.3fs / done: "(e:date "+%Y-%m-%d %H:%M:%S") $m[duration])"\n" red italic)
    }
  }
]

