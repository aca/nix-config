# Remote tmux and SSH panes

This note documents what the local tmux server can detect, why SSH panes are
special, and how the experimental remote split bindings in `tmux.conf` are meant
to work.

## Mental model

There are two different tmux servers when using tmux over SSH:

- outer tmux: the tmux running on the local machine
- inner tmux: the tmux running on the remote machine through SSH

The outer tmux only owns the local PTY. If the pane is running `ssh`, the outer
tmux can usually see only this:

```text
outer tmux pane -> local ssh process -> encrypted SSH stream -> remote shell/tmux
```

That means outer tmux can know the local pane path and the foreground local
command, but it cannot inspect the remote shell's current directory. The remote
current directory is only known by the remote shell or by the inner tmux.

`#{pane_current_path}` follows this rule:

- in a local shell pane: path of the local foreground process
- in an SSH pane from the outer tmux: usually the local directory where `ssh`
  was started, not the remote directory
- in the inner remote tmux: the remote pane's current directory

So if the goal is "split at the remote cwd", the split has to be performed by
the inner remote tmux, not by the outer local tmux.

## What the experimental bindings do

The path-sensitive bindings in `tmux.conf` currently branch on
`@remote-pane-detected`.

That format returns true when either of these is true:

```tmux
#{==:#{pane_current_command},ssh}
```

or `#{pane_path}` is a `file://host/path` URI whose host is not the local tmux
host.

When this is false, the binding behaves like a normal local split:

```tmux
split-window -c "#{pane_current_path}"
```

When this is true, outer tmux assumes the pane is an SSH pane attached to an
inner remote tmux. It sends keys into the pane instead of splitting locally:

```text
send-prefix
send-keys :
send-keys -l 'split-window -c "#{pane_current_path}"'
send-keys Enter
```

The important detail is that the command is typed into the inner tmux command
prompt. The literal `#{pane_current_path}` should be expanded by the inner tmux,
where it means the remote cwd.

This is not a new SSH session. It creates a pane inside the remote tmux session.

## Requirements

This only works when all of these are true:

- the current outer tmux pane's foreground command is detected as `ssh`
- the SSH pane is currently showing an inner remote tmux client
- the inner remote tmux accepts the same prefix sent by `send-prefix`
- `:` opens the inner tmux command prompt
- the inner tmux supports `split-window -c "#{pane_current_path}"`

It will not work in a plain SSH shell without remote tmux. In that case the
outer tmux can send text, but there is no inner tmux command prompt to receive
the command.

It also will not work when the detected foreground command is not exactly `ssh`.
Examples include `mosh-client`, `autossh`, wrapper scripts, or a shell that has
not put `ssh` in the foreground from tmux's point of view.

## Debugging

First make sure the config you edited is actually loaded. In this workspace the
file is:

```sh
/home/rok/src/github.com/aca/nix-config/pkgs/tmux/tmux.conf
```

But the current reload binding points at:

```sh
${HOME}/src/git.internal/nix-config/pkgs/tmux/tmux.conf
```

If that path does not exist on this machine, `prefix R` is not reloading this
file. Source it directly while testing:

```sh
tmux source-file /home/rok/src/github.com/aca/nix-config/pkgs/tmux/tmux.conf
```

Then verify the binding is loaded:

```sh
tmux list-keys | rg 'remote ssh detected'
```

In the pane where the binding fails, check what outer tmux sees:

```sh
tmux display-message -p 'cmd=#{pane_current_command} path=#{pane_current_path} tty=#{pane_tty}'
```

If `cmd` is not `ssh` and `pane_path` is empty or points at the local host, the
remote branch will not run.

For a deeper local view:

```sh
ps -o pid,ppid,pgid,stat,comm,args -t "$(tmux display-message -p '#{pane_tty}')"
```

If the remote branch runs, the status line should briefly show:

```text
remote pane detected: cmd=<command> pane_path=<pane_path>
```

If the local branch runs, the status line should briefly show one of:

```text
local split: cmd=<command> path=<path>
local hsplit: cmd=<command> path=<path>
local new-window: cmd=<command> path=<path>
```

That means the binding is loaded, but the pane did not match the SSH detection
condition.

If that message appears but the remote split does not happen, the detection is
working and the failure is inside the key forwarding path to the inner tmux.
Check the remote tmux prefix and whether `:` opens the command prompt there.

## Remote OSC 7 setup

For plain SSH, a remote shell can make the outer local tmux see the remote cwd by
printing OSC 7:

```sh
printf '\033]7;file://%s%s\007' "$(hostname)" "$PWD"
```

When the shell is inside remote tmux, plain OSC 7 is consumed by the remote tmux.
To pass it through to the outer local tmux, wrap it in tmux passthrough:

```sh
printf '\033Ptmux;\033\033]7;file://%s%s\007\033\\' "$(hostname)" "$PWD"
```

This requires the remote tmux server to allow passthrough:

```tmux
set -g allow-passthrough on
```

I tested this against `ssh mac`: direct OSC 7 updated the outer pane's
`#{pane_path}`, and the tmux-wrapped OSC 7 also updated it from inside a remote
tmux pane.

Once this is installed in the remote shell prompt hook, local tmux can detect a
remote pane from `#{pane_path}` even when `#{pane_current_command}` is not
reported as `ssh`.

For this repo's Elvish setup, that hook lives in `pkgs/elvish/interactive.elv`.

## Safer alternatives

The most reliable setup is to keep local and remote splitting separate:

- normal `"` and `%`: always split locally
- dedicated remote split keys: always send a command to the inner tmux

That avoids guessing from `#{pane_current_command}`. It also makes failures more
obvious: the dedicated remote key only makes sense while the pane is showing a
remote tmux client.

Another approach is to create a new local pane that starts another SSH
connection to the same host. That requires separate host detection and usually
SSH ControlMaster for connection reuse. It still does not solve the remote cwd
problem unless the remote shell reports cwd back to the local terminal, for
example with OSC 7 shell integration.
