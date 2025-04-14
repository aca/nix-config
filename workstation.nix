{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}: let
in {
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nanum
    ibm-plex
  ];
}
