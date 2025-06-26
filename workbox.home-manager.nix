{
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rok";
  home.homeDirectory = "/home/rok";

  imports = [
    ./pkgs/sway/config.nix
    ./pkgs/vifm/vifmrc.nix
    ./pkgs/rofi/rofi.nix
    ./pkgs/home_defaults.nix
    ./pkgs/firefox/firefox.nix
    ./pkgs/alacritty/home.alacritty.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # https://github.com/nix-community/home-manager/issues/355#issuecomment-524042996
  systemd.user.startServices = true;

  home.packages = [
    pkgs.home-manager
  ];

  # systemd.user.services."proxy-socks5" = {
  #   # socks5 proxy
  #   # https_proxy="socks5://localhost:1337" http_proxy="socks5://localhost:1337" curl -vv https://naver.com
  #   Install.WantedBy = ["default.target"];
  #   Service = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/ssh -o StrictHostKeychecking=no -D 1337 -q -C root@64.110.69.249 "sh -c 'sleep 24h; echo 1'"
  #     '';
  #   };
  # };

  # systemd.user.services."qbittorrent-nox" = {
  #   Install.WantedBy = ["default.target"];
  #   # Unit = {
  #   #   After = ["proxy-socks5.service"];
  #   # };
  #   Service = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/qbittorrent-nox
  #     '';
  #   };
  # };

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
  #
  # home.file."${config.xdg.configHome}/qBittorrent/qBittorrent.conf" = {
  #   force = true;
  #   text = builtins.readFile ./pkgs/qBittorrent/seedbox.qBittorrent.conf;
  # };
}
