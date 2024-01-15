{
  config,
  pkgs,
  lib,
  ...
}: {
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.username = "rok";
  home.homeDirectory = "/home/rok";

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
