{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  # dotfiles = "32";
  # https://discourse.nixos.org/t/difference-between-fetchgit-and-fetchgit/3619/5
  dotfiles = builtins.fetchGit {
    url = "https://github.com/aca/dotfiles";
    ref = "main";
    rev = "9e34acec09f52a5a112ef3d712f8dab4d7633029";
    submodules = true;
  };
in {
  imports = [
    ./pkgs/home.ghostty.nix
    ./pkgs/sway/config.nix
    ./pkgs/elvish/elvish.nix
    ./pkgs/vifm/vifmrc.nix
    ./pkgs/rofi/rofi.nix
    ./pkgs/home_defaults.nix
    ./pkgs/alacritty/home.alacritty.nix
  ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rok";
  home.homeDirectory = "/home/rok";
  # home.file.".gitconfig".source = "${inputs.dotfiles.outPath}";

  # builtins.fetchGit { url = "https://github.com/aca/dotfiles"; };
  # home.file."${config.xdg.configHome}/xxx".source = (builtins.fetchGit { url = "https://github.com/aca/dotfiles"; }).outPath;
  home.file.".local/share/nvim/site".source = "${dotfiles.outPath}/.local/share/nvim/site";
  home.file."${config.xdg.configHome}/nvim".source = "${dotfiles.outPath}/.config/nvim";

  home.file.".config/mpv".source = "${dotfiles.outPath}/.config/mpv";
  home.file.".config/qbt".source = "${dotfiles.outPath}/.config/qbt";
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

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

  xdg.desktopEntries.qbt-torrent-add = {
    name = "qbt-torrent-add";
    exec = "/home/rok/src/github.com/aca/dotfiles/.bin/qbt-torrent-add %u";
  };

  # NOTES: this is managed by dotfiles, maybe use nix later?
  xdg.mimeApps.enable = false;
  xdg.mimeApps = {
    defaultApplications."x-scheme-handler/http" = ["vivaldi-stable.desktop"];
    defaultApplications."x-scheme-handler/https" = ["vivaldi-stable.desktop"];
    defaultApplications."text/html" = ["vivaldi-stable.desktop"];
    defaultApplications."x-scheme-handler/about" = ["vivaldi-stable.desktop"];
    defaultApplications."x-scheme-handler/unknown" = ["vivaldi-stable.desktop"];

    defaultApplications."x-scheme-handler/magnet" = ["qbt-torrent-add.desktop"];
    defaultApplications."application/x-bittorrent" = ["qbt-torrent-add.desktop"];

    defaultApplications."x-scheme-handler/tg" = ["telegram.desktop.desktop"];
  };

  programs.firefox = {
    enable = true;
    package = pkgs.unstable.firefox-devedition-bin.override {
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
        "toolkit.startup.max_resumed_crashes" = 0;
        "browser.sessionstore.resume_from_crash" = 0;
        "browser.sessionstore.max_resumed_crashes" = 0;
        "toolkit.startup.recent_crashes" = 0;
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
        # "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # don't submit backlogged reports
        # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # "browser.onboarding.enabled" = false;
        # "browser.download.dir" = "${config.user.home}/Downloads";
      };
      # name = "default";
      name = "dev-edition-default";
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        # bypass-paywalls-clean
        tridactyl
      ];

      userChrome = builtins.readFile ./pkgs/firefox/userChrome.css;

      # https://github.com/crambaud/waterfall
    };
  };

  # https://github.com/nix-community/home-manager/issues/355#issuecomment-524042996
  systemd.user.startServices = true;

  home.packages = [
  ];
}
