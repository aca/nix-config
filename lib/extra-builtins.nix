{ exec, ... }:
{
  readSops =
    name:
    import (exec [
      # "/usr/bin/env" "bash" "-c" "echo '\"secret\"'"
      "age"
      "--decrypt"
      "--identity"
      "/home/rok/.ssh/id_ed25519"
      name
    ]);
}
