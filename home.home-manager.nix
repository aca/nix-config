{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  dotfiles = builtins.fetchGit {
    url = "https://github.com/aca/dotfiles";
    ref = "main";
    inherit (inputs.dotfiles) rev;
    submodules = true;
  };
in {
  imports = [
    ./pkgs/sway/config.nix
    ./pkgs/vifm/vifmrc.nix
    ./pkgs/rofi/rofi.nix
    ./pkgs/home_defaults.nix
    ./pkgs/alacritty/home.alacritty.nix
  ];


  home.stateVersion = "24.11";
  home.username = "rok";
  home.homeDirectory = "/home/rok";

  home.packages = [
    (pkgs.buildFHSUserEnv {
      name = "pixi";
      runScript = "pixi";
      targetPkgs = pkgs: with pkgs; [ pixi ];
    })
  ];

  # home.file.".local/share/nvim/site".source = "${dotfiles.outPath}/.local/share/nvim/site";
  # home.file."${config.xdg.configHome}/nvim".source = "${dotfiles.outPath}/.config/nvim";
  # home.file.".config/mpv".source = "${dotfiles.outPath}/.config/mpv";

  #  TODO: https://github.com/yuanw/nix-home/blob/main/modules/browsers/firefox.nix
  # programs.firefox =
  #   {
  #     enable = true;
  #     package = pkgs.unstable.firefox-devedition.override {
  #     # package = pkgs.firefox.override {
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

  xdg.desktopEntries.qbt-torrent-add = {
    name = "qbt-torrent-add";
    exec = "/home/rok/src/github.com/aca/dotfiles/bin/qbt-torrent-add %u";
  };



  # xdg-mime query filetype XXX.toml
  # xdg-mime query filetype XXX.ext
  xdg.mimeApps.enable = true;
  xdg.mimeApps = {
    # NOTES: this is managed by dotfiles, maybe use nix later?
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
  # Note to other users: the problem of old services being never deleted can be avoided by setting 
  # systemd.user.startServices to true, if no services have failed yet. 
  # Otherwise, you need to systemctl --user reset-failed the degraded services before calling home-manager.
  systemd.user.startServices = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      nativeMessagingHosts = [
        pkgs.tridactyl-native
        pkgs.plasma-browser-integration
      ];
    };
    profiles.default = {
      id = 0;
      settings = {
        # "browser.startup.homepage" = "about:blank";
        # "browser.urlbar.placeholderName" = "Google";
        "app.update.auto" = false;
        "browser.tabs.crashReporting.sendReport" = false;
        "dom.reporting.crash.enabled" = false;
        "services.sync.prefs.sync-seen.browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "services.sync.prefs.sync.browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # don't submit backlogged reports
        "toolkit.startup.max_resumed_crashes" = 0;
        "browser.sessionstore.resume_from_crash" = 0;
        "browser.sessionstore.max_resumed_crashes" = 0;
        "toolkit.startup.recent_crashes" = 0;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # "browser.aboutConfig.showWarning" =
        # "browser.startup.page" = 3; # Restore previous session
        #
        # "browser.newtabpage.enabled" = falsew
        # "browser.newtab.url" = "about:blank";
        #
        # "browser.warnOnQuit" = false;
        # "browser.shell.checkDefaultBrowser" = false;
        # "devtools.theme" = "dark";
        #
        # "ui.systemUsesDarkTheme" = 1;
        # "toolkit.telemetry.unified" = false;
        # "toolkit.telemetry.enabled" = false;
        # "toolkit.telemetry.server" = "data:,";
        # "toolkit.telemetry.archive.enabled" = false;
        # "toolkit.telemetry.coverage.opt-out" = true;
        #
        # # Disable crash reports
        # "breakpad.reportURL" = "";
        # "browser.tabs.crashReporting.sendReport" = false;
        # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # "browser.onboarding.enabled" = false;
        # "browser.download.dir" = "${config.user.home}/Downloads";
      };
      name = "default";
      # name = "dev-edition-default";
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        # bypass-paywalls-clean
        tridactyl
      ];

      userChrome = builtins.readFile ./pkgs/firefox/userChrome.css;
      # userContent = builtins.readFile ./pkgs/firefox/userContent.css;

      # https://github.com/crambaud/waterfall
    };
  };

}
