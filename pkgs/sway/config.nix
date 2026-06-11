{
  config,
  pkgs,
  lib,
  ...
}:
let
  hostname = lib.strings.trim (builtins.readFile /etc/hostname);
in
{
  home.file."${config.xdg.configHome}/sway/config".text =
    builtins.readFile ./config
    + lib.optionalString (builtins.pathExists (./. + "/config-${hostname}")) (builtins.readFile (./. + "/config-${hostname}"));
  home.file."${config.xdg.configHome}/sway/env".text =
    builtins.readFile ./env;
  home.file."${config.xdg.configHome}/sway/config-keyboard".text =
    builtins.readFile ./config-keyboard;
}
