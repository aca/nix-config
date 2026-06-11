use str

fn elvish-escape {|cmd|
  str:replace "'" "''" $cmd
}

# test that elvish single-quoting roundtrips correctly:
# escape the string, then eval it, and check we get the original back
fn test {|name cmd|
  var escaped = "'"(elvish-escape $cmd)"'"
  var got = (eval "put "$escaped)
  if (eq $got $cmd) {
    echo "PASS: "$name
  } else {
    echo "FAIL: "$name
    echo "  original: "$cmd
    echo "  escaped:  "$escaped
    echo "  got:      "$got
  }
}

test "simple" "echo hello"
test "single quotes" "echo 'hello world'"
test "double quotes" 'echo "hello world"'
test "newline" "echo a\necho b"
test "wildcard" "cp -avn * new/"
test "dollar" 'echo $HOME'
test "backtick" 'echo `whoami`'
test "mixed" "echo \"it's a 'test'\""
