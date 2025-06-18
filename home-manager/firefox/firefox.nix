{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  isNixOS = builtins.pathExists /etc/nixos;
in {
  programs.firefox = {
    enable = true;
    # package = pkgs.firefox-devedition;
    package = lib.mkDefault (
      if isNixOS
      then
        pkgs.firefox-devedition.override {
          nativeMessagingHosts = [
            pkgs.tridactyl-native
            # pkgs.plasma-browser-integration
          ];
        }
      else pkgs.firefox-devedition-bin
    );
    policies = {
      DisablePocket = true;
      # ---- EXTENSIONS ----
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
      ExtensionSettings = {
        # ctrl + number for firefox
        "{84601290-bec9-494a-b11c-1baa897a9683}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4192880/ctrl_number_to_switch_tabs-1.0.2.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    profiles.dev-edition-default = {
      # id = 0;
      # name = "profile_0";
      # settings = {
      #   # "browser.startup.homepage" = "about:blank";
      #   # "browser.urlbar.placeholderName" = "Google";
      #   "app.update.auto" = false;
      #   "browser.tabs.crashReporting.sendReport" = false;
      #   "dom.reporting.crash.enabled" = false;
      #   "services.sync.prefs.sync-seen.browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      #   "services.sync.prefs.sync.browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      #   "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # don't submit backlogged reports
      #   "toolkit.startup.max_resumed_crashes" = 0;
      #   "browser.sessionstore.resume_from_crash" = 0;
      #   "browser.sessionstore.max_resumed_crashes" = 0;
      #   "toolkit.startup.recent_crashes" = 0;
      #   "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      #   "browser.fullscreen.autohide" = false;
      #   # "browser.aboutConfig.showWarning" =
      #   # "browser.startup.page" = 3; # Restore previous session
      #   #
      #   # "browser.newtabpage.enabled" = falsew
      #   # "browser.newtab.url" = "about:blank";
      #   #
      #   # "browser.warnOnQuit" = false;
      #   # "browser.shell.checkDefaultBrowser" = false;
      #   # "devtools.theme" = "dark";
      #   #
      #   # "ui.systemUsesDarkTheme" = 1;
      #   # "toolkit.telemetry.unified" = false;
      #   # "toolkit.telemetry.enabled" = false;
      #   # "toolkit.telemetry.server" = "data:,";
      #   # "toolkit.telemetry.archive.enabled" = false;
      #   # "toolkit.telemetry.coverage.opt-out" = true;
      #   #
      #   # # Disable crash reports
      #   # "breakpad.reportURL" = "";
      #   # "browser.tabs.crashReporting.sendReport" = false;
      #
      #   # "browser.onboarding.enabled" = false;
      #   # "browser.download.dir" = "${config.user.home}/Downloads";
      # };
      isDefault = true;
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        # firefox-ctrlnumber
        ublock-origin
        # bypass-paywalls-clean
        tridactyl
      ];

      # NOTE: about:config should be set manually, "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      # setting profile doesn't work well
      userChrome = builtins.readFile ./userChrome.css;
      # userContent = builtins.readFile ./pkgs/firefox/userContent.css;

      # https://github.com/crambaud/waterfall
    };
  };
}
