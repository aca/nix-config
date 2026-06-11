use str

set edit:insert:binding[Alt-q] = {||
  if (not-eq $edit:current-command "") {
    var escaped = (str:replace "'" "''" $edit:current-command)
    edit:replace-input "cq -- elvish -c '"$escaped"'"
    edit:smart-enter
  }
}
