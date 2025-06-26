{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  dotfiles = builtins.fetchGit {
    url = "https://codeberg.org/aca/dotfiles";
    ref = "main";
    inherit (inputs.dotfiles) rev;
    submodules = true;
  };
in {
  imports = [
    ./pkgs/sway/config.nix
    ./pkgs/rofi/rofi.nix
    ./pkgs/home_defaults.nix
    ./pkgs/alacritty/home.alacritty.nix
    ./home-manager/desktop.nix
  ];

  home.stateVersion = "25.05";
  home.username = "rok";
  home.homeDirectory = "/home/rok";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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

  # systemd.user.services."proxy-socks5" = {
  #   # socks5 proxy
  #   # https_proxy="socks5://localhost:1337" http_proxy="socks5://localhost:1337" curl -vv https://naver.com
  #   Install.WantedBy = ["default.target"];
  #   Service = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/ssh -D 1337 -q -C root@oci-xnzm-002 "sh -c 'sleep 24h; echo 1'"
  #     '';
  #   };
  # };
  #
  # systemd.user.services."qbittorrent-nox" = {
  #   Install.WantedBy = ["default.target"];
  #   Unit = {
  #     After = ["proxy-socks5.service"];
  #   };
  #   Service = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/qbittorrent-nox
  #     '';
  #   };
  # };

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
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
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

  # xdg.mime =
  #   # list from /run/current-system/sw/share/applications
  #   let
  #     browser = "floorp.desktop";
  #     torrent = "org.qbittorrent.qBittorrent.desktop";
  #     imgviewer = "org.kde.gwenview.desktop";
  #   in {
  #     defaultApplications = {
  #       "text/html" = "${browser}";
  #       "x-scheme-handler/http" = "${browser}";
  #       "x-scheme-handler/https" = "${browser}";
  #       "x-scheme-handler/about" = "${browser}";
  #       "x-scheme-handler/unknown" = "${browser}";
  #
  #       "x-scheme-handler/magnet" = "${torrent}";
  #       "application/x-bittorrent" = "${torrent}";
  #
  #       "image/jpeg" = "${imgviewer}";
  #       "image/png" = "${imgviewer}";
  #       "image/gif" = "${imgviewer}";
  #       "image/bmp" = "${imgviewer}";
  #       "image/svg+xml" = "${imgviewer}";
  #       "image/tiff" = "${imgviewer}";
  #     };
  #   };

  # https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s07.html
  xdg.desktopEntries.qbt-torrent-add = {
    name = "qbt-torrent-add";
    exec = "qbt torrent add %u";
  };

  xdg.mimeApps.enable = true;
  xdg.mimeApps = {
    # xdg-mime query default application/x-bittorrent
    defaultApplications."x-scheme-handler/http" = ["vivaldi-stable.desktop"];
    defaultApplications."x-scheme-handler/https" = ["vivaldi-stable.desktop"];
    defaultApplications."text/html" = ["vivaldi-stable.desktop"];
    defaultApplications."x-scheme-handler/about" = ["vivaldi-stable.desktop"];
    defaultApplications."x-scheme-handler/unknown" = ["vivaldi-stable.desktop"];

    defaultApplications."x-scheme-handler/magnet" = ["qbt-torrent-add.desktop"];
    defaultApplications."application/x-bittorrent" = ["qbt-torrent-add.desktop"];

    defaultApplications."x-scheme-handler/tg" = ["telegram.desktop.desktop"];
  };

  # programs.firefox = {
  #   enable = true;
  #   package = pkgs.unstable.firefox-devedition-bin.override {
  #     nativeMessagingHosts = [
  #       pkgs.tridactyl-native
  #       pkgs.plasma-browser-integration
  #     ];
  #   };
  #   profiles.default = {
  #     id = 0;
  #     settings = {
  #       # "browser.startup.homepage" = "about:blank";
  #       # "browser.urlbar.placeholderName" = "Google";
  #       "app.update.auto" = false;
  #       "browser.tabs.crashReporting.sendReport" = false;
  #       "dom.reporting.crash.enabled" = false;
  #       "services.sync.prefs.sync-seen.browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
  #       "services.sync.prefs.sync.browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
  #       "toolkit.startup.max_resumed_crashes" = 0;
  #       "browser.sessionstore.resume_from_crash" = 0;
  #       "browser.sessionstore.max_resumed_crashes" = 0;
  #       "toolkit.startup.recent_crashes" = 0;
  #       # "browser.aboutConfig.showWarning" =
  #       # "browser.startup.page" = 3; # Restore previous session
  #       #
  #       # "browser.newtabpage.enabled" = falsew
  #       # "browser.newtab.url" = "about:blank";
  #       #
  #       # "browser.warnOnQuit" = false;
  #       # "browser.shell.checkDefaultBrowser" = false;
  #       # "devtools.theme" = "dark";
  #       #
  #       # "ui.systemUsesDarkTheme" = 1;
  #       # "toolkit.telemetry.unified" = false;
  #       # "toolkit.telemetry.enabled" = false;
  #       # "toolkit.telemetry.server" = "data:,";
  #       # "toolkit.telemetry.archive.enabled" = false;
  #       # "toolkit.telemetry.coverage.opt-out" = true;
  #       #
  #       # # Disable crash reports
  #       # "breakpad.reportURL" = "";
  #       # "browser.tabs.crashReporting.sendReport" = false;
  #       # "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # don't submit backlogged reports
  #       # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  #
  #       # "browser.onboarding.enabled" = false;
  #       # "browser.download.dir" = "${config.user.home}/Downloads";
  #     };
  #     # name = "default";
  #     name = "dev-edition-default";
  #     isDefault = true;
  #     extensions = with pkgs.nur.repos.rycee.firefox-addons; [
  #       ublock-origin
  #       # bypass-paywalls-clean
  #       tridactyl
  #     ];
  #
  #     userChrome = builtins.readFile ./pkgs/firefox/userChrome.css;
  #
  #     # https://github.com/crambaud/waterfall
  #   };
  # };

  # https://github.com/nix-community/home-manager/issues/355#issuecomment-524042996
  systemd.user.startServices = true;
}
