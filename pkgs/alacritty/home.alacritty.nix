{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.xdg.configHome}/alacritty/alacritty.toml".text =
    (builtins.readFile ./alacritty.toml)
    + (
      if pkgs.stdenv.isDarwin
      then ''
        # background-opacity = 0.8
      ''
      else ''''
    );
}
