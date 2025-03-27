{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.home.homeDirectory}/.gitconfig".text = builtins.readFile ./.gitconfig;
  home.file."${config.home.homeDirectory}/.gitconfig.git.internal".text = ''
[init]
    # for cgit to work
    defaultBranch = master
  '';
}
