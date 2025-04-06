{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
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

      userChrome = builtins.readFile ./userChrome.css;
      # userContent = builtins.readFile ./pkgs/firefox/userContent.css;

      # https://github.com/crambaud/waterfall
    };
  };
}
