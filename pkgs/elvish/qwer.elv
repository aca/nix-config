use str

# find-completion 'qwer echo xxx yyy' 'qwer e'      # Returns: echo
# find-completion 'qwer echo xxx yyy' 'qwer echo'   # Returns: xxx
# find-completion 'qwer echo xxx yyy' 'qwer echo '  # Returns: xxxRetry
fn find-completion {|full partial|
  var full-words = [(str:split ' ' $full)]
  var partial-words = [(str:split ' ' $partial)]
  
  # Determine if we need to complete current word or suggest next
  var last-partial = $partial-words[-1]
  var position = (- (count $partial-words) 1)
  
  # Check if the word at current position is complete
  if (and (< $position (count $full-words)) (eq $full-words[$position] $last-partial)) {
    # Word is complete, return next word
    var next-pos = (+ $position 1)
    if (< $next-pos (count $full-words)) {
      echo $full-words[$next-pos]
    }
  } elif (< $position (count $full-words)) {
    # Word is incomplete, check if it's a prefix
    if (str:has-prefix $full-words[$position] $last-partial) {
      echo $full-words[$position]
    }
  }
}

set edit:completion:arg-completer[qwer] = {|@args|
    var partial-cmd = [(drop 1 $args)]
    var current-input = (str:trim-space (str:join ' ' $partial-cmd))

    # notify-send $partial-cmd

    qwer --list | each { |line|
        if (not (str:has-prefix $line $current-input)) {
            continue
        }

        find-completion $line $current-input
    }
}
