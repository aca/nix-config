{ exec, ... }:
{
  readSops = identity: name:
    import (exec [ ./decrypt.sh identity nixFile ]);
}
