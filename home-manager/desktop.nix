{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
in {
  imports = [
    ./firefox/firefox.nix
  ];

  # home.stateVersion = "25.05";
  # home.username = "rok";
}
