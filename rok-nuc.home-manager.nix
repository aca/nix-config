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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # https://github.com/nix-community/home-manager/issues/355#issuecomment-524042996
  systemd.user.startServices = true;

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

  systemd.user.services."proxy-socks5" = {
    # socks5 proxy
    # https_proxy="socks5://localhost:1337" http_proxy="socks5://localhost:1337" curl -vv https://naver.com
    Install.WantedBy = ["default.target"];
    Service = {
      Type = "exec";
      ExecStart = ''
        /run/current-system/sw/bin/ssh -D 1337 -q -C root@oci-xnzm1001-002 "sh -c 'sleep 24h; echo 1'"
      '';
    };
  };

  # systemd.user.services."dura" = {
  #   Install.WantedBy = ["default.target"];
  #   Service = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/dura serve
  #     '';
  #   };
  # };

  # systemd.user.services."takes30s" = {
  #   Install.WantedBy = [ "default.target" ];
  #   Service = {
  #     Type = "notify";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/bash /home/rok/bin/waiter
  #     '';
  #   };
  # };

  # systemd.user.services."hellosystemd" = {
  #   Install.WantedBy = [ "default.target" ];
  #   Unit = {
  #     After = [ "takes30s.service" ];
  #   };
  #   Service = {
  #     Type = "notify";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/bash /home/rok/bin/waiter
  #     '';
  #   };
  # };

  # systemd.user.services."proxy-test" = {
  #   Install.WantedBy = [ "default.target" ];
  #   Unit = {
  #     After = [ "proxy-socks5.service" ];
  #   };
  #   Service = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/curl --proxy "socks5://localhost:1337" https://ifconfig.me;
  #       /run/current-system/sw/bin/sleep 1000
  #     '';
  #   };
  # };

  # virt-manager
  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = ["qemu:///system"];
  #     uris = ["qemu:///system"];
  #   };
  # };

  systemd.user.services."qbittorrent-nox" = {
    Install.WantedBy = ["default.target"];
    Unit = {
      After = ["proxy-socks5.service"];
    };
    Service = {
      Type = "exec";
      ExecStart = ''
        /run/current-system/sw/bin/qbittorrent-nox
      '';
    };
  };

  #  TODO: https://github.com/yuanw/nix-home/blob/main/modules/browsers/firefox.nix
  # programs.firefox =
  #   {
  #     enable = true;
  #     # package = pkgs.unstable.firefox-devedition.override {
  #     package = pkgs.firefox.override {
  #       cfg = {
  #         # Gnome shell native connector
  #         enableGnomeExtensions = true;
  #         # Tridactyl native connector
  #         enableTridactylNative = true;
  #       };
  #     };
  #   };

  # xdg.mimeApps = {
  #   defaultApplications."x-scheme-handler/http" = ["firefox.desktop" "chromium.desktop" "qutebrowser.desktop"];
  #   defaultApplications."x-scheme-handler/https" = ["firefox.desktop" "chromium.desktop" "qutebrowser.desktop"];
  #   defaultApplications."text/html" = ["firefox.desktop"];
  #   defaultApplications."x-scheme-handler/about" = ["firefox.desktop"];
  #   defaultApplications."x-scheme-handler/unknown" = ["firefox.desktop"];
  # };

  home.packages = [
  ];
}
