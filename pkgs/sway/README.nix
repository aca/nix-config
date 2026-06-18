

  Option 2: Use builtins.readFile on /etc/hostname at build time

  let
    hostname = lib.strings.trim (builtins.readFile /etc/hostname);
  in { ... }

  This reads the hostname of the build machine, which works if you always build locally. It won't work for remote builds or nixos-rebuild --target-host.
