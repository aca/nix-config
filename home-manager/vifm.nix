{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.vifm.extraConfig = ''
  set millerview
  '';
}
