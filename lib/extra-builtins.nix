{ exec, ... }:
{
  readSops = identity: name:
    builtins.fromJSON (exec [ "age" "--decrypt" "-i" identity name ]);
}
