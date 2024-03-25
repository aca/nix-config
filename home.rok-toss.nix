{
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "kyungrok.chung";

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

  home.packages = [
    pkgs.inetutils
    # pkgs.htop
    # pkgs.bfs
    # pkgs.pueue
  ];

  programs.firefox = {
    enable = true;
    # nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
    package = pkgs.firefox-devedition-bin;
    policies = {
          ManualAppUpdateOnly = true;
    };
    profiles.default = {
      id = 0;
      settings = {
        # "browser.startup.homepage" = "about:blank";
        # "browser.urlbar.placeholderName" = "Google";
        # "app.update.auto" = false;
        # "browser.aboutConfig.showWarning" = false;
        # "browser.startup.page" = 3; # Restore previous session
        #
        # "browser.newtabpage.enabled" = false;
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
        #
        # "browser.onboarding.enabled" = false;
        # # "browser.download.dir" = "${config.user.home}/Downloads";
      };
      name = "default";
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        # bypass-paywalls-clean
        tridactyl
      ];

      # userChrome = ''
      #   @import "${
      #     builtins.fetchGit {
      #       url = "https://github.com/rockofox/firefox-minima";
      #       ref = "main";
      #       rev = "976564bbbab3df0deafcba3e6e9f73ca7ad3b4ad"; # <-- Change this
      #     }
      #   }/userChrome.css";
      # '';

      userChrome = builtins.readFile ./pkgs/firefox/userChrome.css;
    };
  };
}
