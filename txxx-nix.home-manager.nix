{
  config,
  pkgs,
  lib,
  inputs,
  # inputs,
  ...
}: let
in {
  imports = [
    ./pkgs/home_defaults.nix
    ./pkgs/elvish/elvish.nix
    ./pkgs/vifm/vifmrc.nix
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.username = "rok";
  home.homeDirectory = "/home/rok";

  #
  # home.sessionVariables = {
  #   EXAMPLE_VAR = (builtins.fromJSON (builtins.readFile config.age.secrets.txxx.path)).workdir;
  # };

  home.file.".config/mpv".source = "${inputs.dotfiles.outPath}/.config/mpv";

  services.pueue = {
    enable = true;
    settings = {
      client = {
        dark_mode = true;
        show_expanded_aliases = false;
      };
      daemon = {
        default_parallel_tasks = 1;
        pause_group_on_failure = false;
        pause_all_on_failure = false;
      };
      shared = {
        use_unix_socket = true;
      };
    };
  };

  home.packages = [
  ];

  # home-manager.users.myuser = {
  #   dconf = {
  #     enable = true;
  #     settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  #   };
  # };
}
