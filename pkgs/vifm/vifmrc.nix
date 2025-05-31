{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.xdg.configHome}/vifm/vifmrc".text =
    (builtins.readFile ./vifmrc)

    # + ''
    #   if filereadable(expand('$HOME/.vifmrc.local'))
    #       source ~/.vifmrc.local
    #   endif
    # ''

    + (
      if pkgs.stdenv.isDarwin
      then (builtins.readFile ./vifmrc-osx)
      else (builtins.readFile ./vifmrc-linux)
    );
}
