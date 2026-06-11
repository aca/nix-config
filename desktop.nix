{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}:
let
in
{
  imports = [
    # ./env.nix
    # ./dev/default_ssh.nix
    # ./pkgs/scripts.nix
    # ./pkgs/tmux/tmux.nix
  ];

  environment.systemPackages = [
    pkgs.element-desktop
    pkgs.easyeffects
  ];

}
