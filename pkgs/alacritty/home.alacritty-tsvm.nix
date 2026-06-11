{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.file."${config.xdg.configHome}/alacritty/alacritty.toml".text =
    builtins.readFile ./alacritty-tsvm.toml;
}
