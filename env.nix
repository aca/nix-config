{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.extraInit =
    (builtins.readFile ./env)
    + (
      if pkgs.stdenv.isDarwin
      then (builtins.readFile ./env_darwin)
      else (builtins.readFile ./env_linux)
    )
    + (
      if pkgs.stdenv.isDarwin
      then ''
        export PATH=$HOME/bin/x:$HOME/bin:$PATH
      ''
      # darwin, /run/current-system/sw/bin # sudo issue, /run/wrappers/bin/sudo should be run
      else ''
        export PATH=$HOME/bin/x:$HOME/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/opt/homebrew/bin:$PATH:
      ''
    );
}
