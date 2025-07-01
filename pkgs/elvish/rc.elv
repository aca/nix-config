use str
use path
use platform
use os
# use interactive

if (not (has-env _ELVISH_INIT)) { 
    stty -ixon # http://www.linusakesson.net/programming/tty/
    set-env _ELVISH_INIT 1
    stty start '^-' stop '^-'  # ctrl-q
}

# use /completion
# use plugins/edit.elv/smart-matcher; smart-matcher:apply
# nop ?(use local)

# move
fn w { nop ?(cd ~/src/scratch/(fd --base-directory ~/src/scratch --strip-cwd-prefix --hidden --type d --max-depth 1 --no-ignore -0 | fzf --read0)) }
fn s {|| cd (fzf.src)}
fn x {|@a| cd (scratch $@a) }
fn d {|@a| cd ~/src/github.com/aca/dotfiles }
fn dot.v {|@a| cd ~/src/github.com/aca/dotfiles/.config/nvim }
fn grt { cd (e:git rev-parse --show-toplevel) }
fn cdf { |p| try { isDir $p; cd $p } catch { cd (dirname $p) } }
fn take { |@a| mkdir -p $@a; cd $a[0] }
fn ffc { |@a| $cdf~ (ff)  }

# basics
fn make {|@a| e:make --directory (rootdir Makefile $E:HOME) $@a }

# wrappers
fn ghq { |@a| e:ghq $@a; sh -c "src.updateindex &" }
fn ghqbare { |@a| e:ghq clone --bare $@a;  ;sh -c "src.updateindex &" }
# fn ntfy {|@a| e:ntfy $@a }
fn trash-empty { |@a| yes | e:trash-empty }
fn vifm {|@a| cd (e:vifm $@a --choose-dir -) }; fn f {|@a| vifm $@a}
fn v {|@a| if (has-external nvim) { e:nvim $@a } else { e:vim $@a }}
fn vim {|@a| if (has-external nvim) { e:nvim $@a } else { e:vim $@a }}

# utils
fn from-0 { || from-terminated "\x00" }
fn export { |v| put $v | str:split &max=2 '=' (one) | set-env (all) }
fn history { edit:command-history &dedup &newest-first &cmd-only | to-lines }
fn history.rm { 
    use edit
    use store
    use str
    edit:command-history &dedup &newest-first | each { |x| echo $x[id] ( str:replace "\n" " " $x[cmd] )  } | fzf | awk '{print $1}' | each { |x| store:del-cmd $x }
}


fn str-to-rune-array { |x|
    put [ (str:split '' $x) ]
}

fn ign { |@a|
    # $@a # FIXME: What's wrong with this
    # $a[0] $a[1:] # FIXME: What's wrong with this
    try {
        eval (repr $@a)
    } catch {
        nop   
    }
}

# diff (echo 1 | psub) (echo 2 | psub)
fn psub {
    var output = (mktemp)
    cat > $output
    echo $output
}

# Filters a sequence of items and outputs those for whom the function outputs $true.
# https://github.com/elves/elvish/issues/1721~/.config/elvish/rc.elv:90
#
# fd --type f | grep 'html'
# fd --type f | from-lines | filter { |x| str:contains $x 'html' } [(all)]
#
# fd --type f | grep -v 'html'
# fd --type f | from-lines | filter &not=true { |x| str:contains $x 'html' } [(all)]
#
# filter { |x| > 3 $x } [ 1 2 3 4 ]
fn filter {|pred~ @items &not=$false &out=$put~|
  var ck~ = $pred~
  if $not { set ck~ = {|item| not (pred $item)} }
  each {|item| if (ck $item) { $out $item }} $@items
}

fn activate-venv {
    if (str:has-prefix $pwd $E:HOME/src) {
        if (os:is-dir .venv) {
            try {
                set-env VIRTUAL_ENV $pwd/.venv
                set paths = [ $pwd/.venv/bin $@paths ]
            } catch e {
                nop
            }
        }
    }
}

# if (has-env DISPLAY) {
#     nop
# } else {
#     set-env DISPLAY ":0"
# }

set @edit:before-readline = $@edit:before-readline {
    activate-venv
    try {
        var m = [("direnv" export elvish 2>/dev/null | from-json)]
        # var m = [("direnv" export elvish | from-json)]
        if (> (count $m) 0) {
            set m = (all $m)
            keys $m | each { |k|
                if $m[$k] {
                    set-env $k $m[$k]
                } else {
                    unset-env $k
                }
            }
        }
    } catch e {
        nop
        # echo $e
    }
}

set edit:completion:arg-completer[@] = { |@args| 
    ls (e:rootdir @)/@ | each {|x| edit:complex-candidate $x; } 
}
