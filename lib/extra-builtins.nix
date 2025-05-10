{ exec, ... }:
{
  readSops =
    name:
    exec [
      "/usr/bin/env"
      "bash"
      "-c"
      "echo '\"secret\"'"
    ];
}
