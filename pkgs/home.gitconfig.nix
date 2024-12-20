{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.home.homeDirectory}/.gitconfig".text = builtins.readFile ./.gitconfig;
}
