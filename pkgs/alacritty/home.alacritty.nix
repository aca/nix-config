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
[window]
decorations = "none"
opacity = 0.8
option_as_alt = "Both"
      ''
      else ''''
    );
}
