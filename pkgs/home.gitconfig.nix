{
  config,
  pkgs,
  lib,
  ...
}:
let
  # secrets = (builtins.exec [ "bash" "-c" ''echo "\"$XXX\""'' ]);
in
{
  home.file."${config.home.homeDirectory}/.gitconfig".text = builtins.readFile ./.gitconfig;
  home.file."${config.home.homeDirectory}/.gitconfig.git.internal".text = ''
    [init]
        # for cgit to work
        defaultBranch = master
  '';
  # home.file."${config.home.homeDirectory}/.gitconfig.git.xxx".text = ''
  #   [xxx]
  #     dir = ${secrets};
  # '';
}
