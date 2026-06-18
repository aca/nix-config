
# helper used by `mark-*` functions
fn set-prompt-state {|new| set-env __ghostty_prompt_state $new }

fn mark-prompt-start {
  if (not-eq prompt-start (constantly $E:__ghostty_prompt_state)) {
    printf "\e]133;D\a"
  }
  set-prompt-state 'prompt-start'
  printf "\e]133;A\a"
}

fn mark-output-start {|_|
  set-prompt-state 'pre-exec'
  printf "\e]133;C\a"
}

fn mark-output-end {|cmd-info|
  set-prompt-state 'post-exec'

  var exit-status = 0

  # in case of error: retrieve exit status,
  # unless does not exist (= builtin function failure), then default to 1
  if (not-eq $nil $cmd-info[error]) {
    set exit-status = 1

    if (has-key $cmd-info[error] reason) {
      if (has-key $cmd-info[error][reason] exit-status) {
        set exit-status = $cmd-info[error][reason][exit-status]
      }
    }
  }

  printf "\e]133;D;"$exit-status"\a"
}

# {

  # fn report-pwd {
  #   printf "\e]7;file://%s%s\a" (hostname) (pwd)
  # }

  # fn sudo-with-terminfo {|@args|
  #   var sudoedit = $false
  #   for arg $args {
  #     use str
  #     if (str:has-prefix $arg -) {
  #       if (has-value [e -edit] $arg[1..]) {
  #         set sudoedit = $true
  #         break
  #       }
  #       continue
  #     }
  #
  #     if (not (has-value $arg =)) { break }
  #   }
  #
  #   if (not $sudoedit) { set args = [ TERMINFO=$E:TERMINFO $@args ] }
  #   (external sudo) $@args
  # }

  # defer {
  #   mark-prompt-start
  #   report-pwd
  # }

set edit:before-readline = (conj $edit:before-readline $mark-prompt-start~)
set edit:after-readline  = (conj $edit:after-readline $mark-output-start~)
set edit:after-command   = (conj $edit:after-command $mark-output-end~)

  # var no-title  = (eq 1 $E:GHOSTTY_SHELL_INTEGRATION_NO_TITLE)
  # var no-cursor = (eq 1 $E:GHOSTTY_SHELL_INTEGRATION_NO_CURSOR)
  # var no-sudo   = (eq 1 $E:GHOSTTY_SHELL_INTEGRATION_NO_SUDO)
  #
  # if (not $no-title) {
  #   set after-chdir = (conj $after-chdir {|_| report-pwd })
  # }
  # if (not $no-cursor) {
  #   fn beam  { printf "\e[5 q" }
  #   fn block { printf "\e[0 q" }
  #   set edit:before-readline = (conj $edit:before-readline $beam~)
  #   set edit:after-readline  = (conj $edit:after-readline {|_| block })
  # }
  # if (and (not $no-sudo) (not-eq "" $E:TERMINFO) (has-external sudo)) {
  #   edit:add-var sudo~ $sudo-with-terminfo~
  # }
# }
