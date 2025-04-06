{
  pkgs,
  lib,
  inputs,
  ...
}:
let
in
{
  imports = [
    ./pkgs/home_defaults.nix
    ./pkgs/elvish/elvish.nix
    ./pkgs/firefox/firefox.nix
    # ./pkgs/sway/config.nix

    ./pkgs/vifm/vifmrc.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.username = "rok";
  home.homeDirectory = "/home/rok";

  xsession.initExtra = "xset r rate 200 30";

  # services.pueue = {
  #   enable = true;
  #   settings = {
  #     client = {
  #       dark_mode = true;
  #       show_expanded_aliases = false;
  #     };
  #     daemon = {
  #       default_parallel_tasks = 1;
  #       pause_group_on_failure = false;
  #       pause_all_on_failure = false;
  #     };
  #     shared = {
  #       use_unix_socket = true;
  #     };
  #   };
  # };

  # home.packages = [
  # ];
}
