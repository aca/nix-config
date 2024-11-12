{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.xdg.configHome}/sway/config".text =
    builtins.readFile ./config;
  home.file."${config.xdg.configHome}/sway/env".text =
    builtins.readFile ./env;
  home.file."${config.xdg.configHome}/sway/config-keyboard".text =
    builtins.readFile ./config-keyboard;
}
