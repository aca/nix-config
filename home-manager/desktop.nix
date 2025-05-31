{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
in {
  imports = [
    ./pkgs/sway/config.nix
    ./firefox/firefox.nix
  ];

  # home.stateVersion = "25.05";
  # home.username = "rok";
}
