{ exec, ... }:
{
  # readSops = identity: name:
  #   builtins.fromJSON (exec [ "age" "--decrypt" "-i" identity name ]);
  # builtins.fromJSON (exec [ "age" "--decrypt" "-i" identity name ]);
  readSops = name: exec [ "age" "--decrypt" "-i" "/home/rok/.ssh/id_ed25519" name ];
  # helloWorld = exec ["/usr/bin/env" "bash" "-c" "echo '\"HelloWorld\"'"];
}
