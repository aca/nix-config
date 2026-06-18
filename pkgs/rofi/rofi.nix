{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.xdg.configHome}/rofi/config.rasi".text =
    builtins.readFile ./config.rasi;
}
