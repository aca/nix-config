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
    # ./pkgs/sway/config.nix
    ./pkgs/vifm/vifmrc.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.username = "rok";
  home.homeDirectory = "/home/rok";

  #
  # home.sessionVariables = {
  #   EXAMPLE_VAR = (builtins.fromJSON (builtins.readFile config.age.secrets.txxx.path)).workdir;
  # };

  # home.file.".config/mpv".source = "${inputs.dotfiles.outPath}/.config/mpv";

  xsession.initExtra = "xset r rate 200 30";

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition.override {
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
      name = "default";
      # name = "dev-edition-default";
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

  home.packages = [
  ];

  # home-manager.users.myuser = {
  #   dconf = {
  #     enable = true;
  #     settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  #   };
  # };
  
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
}
