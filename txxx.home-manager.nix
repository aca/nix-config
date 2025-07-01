{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./pkgs/home_defaults.nix

    ./pkgs/vifm/vifmrc.nix
    # ./pkgs/firefox/firefox.nix
    ./pkgs/alacritty/home.alacritty.nix
    ./pkgs/elvish/elvish.nix
  ];

  launchd.agents = {
    restic = {
      enable = true;
      config = {
        Program = /Users/mike/.bin/run-or-notify;
        ProgramArguments = [
          "/Users/mike/.bin/run-or-notify"
          "restic-snapshot failed!"
          "/Users/mike/.bin/restic-snapshot"
        ];
        StartInterval = 21600;
        EnvironmentVariables.PATH = "${pkgs.restic}/bin:/usr/bin";
        StandardErrorPath = "/Users/mike/restic-stderr.txt"; # these lines are how you debug stuff with launchd
        StandardOutPath = "/Users/mike/restic-stdout.txt";
      };
    };
  };

  # programs.firefox.package = pkgs.firefox-devedition-bin;

  # programs.firefox.package = pkgs.wrapFirefox pkgs.firefox-devedition-bin {
  #   extraPolicies = {
  #     DisableAppUpdate = true;
  #     ManualAppUpdateOnly = true;
  #     DisablePocket = true;
  #     DisableSetDesktopBackground = true;
  #     DisableTelemetry = true;
  #   };
  # };

  # programs.firefox.package = pkgs.firefox-bin;
  # programs.firefox.package = pkgs.firefox-bin.override {
  #   nativeMessagingHosts = [
  #     pkgs.tridactyl-native
  #     pkgs.plasma-browser-integration
  #   ];
  # };

  programs.java.enable = true;
  programs.java.package = pkgs.jdk17;

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
  home.stateVersion = "25.05";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
      pkgs.unstable.go
    # pkgs.htop
    # pkgs.bfs
    # pkgs.pueue
  ];

  # programs.firefox = {
  #   enable = false;
  #   # nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
  #   # package = pkgs.firefox-devedition-bin;
  #   package = pkgs.firefox-devedition-bin;
  #   # package = pkgs.wrapFirefox pkgs.firefox-devedition-bin {
  #   #     extraPolicies = {
  #   #           DisableAppUpdate = true;
  #   #           ManualAppUpdateOnly = true;
  #   #           DisablePocket = true;
  #   #           DisableSetDesktopBackground = true;
  #   #           DisableTelemetry = true;
  #   #     };
  #   # };
  #
  #   policies = {
  #     DisableAppUpdate = true;
  #     ManualAppUpdateOnly = true;
  #     DisablePocket = true;
  #     DisableSetDesktopBackground = true;
  #     DisableTelemetry = true;
  #   };
  #   profiles.default = {
  #     id = 0;
  #     # settings = {
  #     #   # "app.update.auto" = false;
  #     #   # "app.update.checkInstallTime" = false;
  #     #   # "browser.startup.homepage" = "about:blank";
  #     #   # "browser.aboutConfig.showWarning" = false;
  #     #   # "browser.warnOnQuit" = false;
  #     #   # "browser.shell.checkDefaultBrowser" = false;
  #     #   # "extensions.pocket.enabled" = false;
  #     #
  #     #   # "browser.urlbar.placeholderName" = "Google";
  #     #   # "app.update.auto" = false;
  #     #   # "browser.startup.page" = 3; # Restore previous session
  #     #   #
  #     #   # "browser.newtabpage.enabled" = false;
  #     #   # "browser.newtab.url" = "about:blank";
  #     #   #
  #     #   # "devtools.theme" = "dark";
  #     #   #
  #     #   # "ui.systemUsesDarkTheme" = 1;
  #     #   # "toolkit.telemetry.unified" = false;
  #     #   # "toolkit.telemetry.enabled" = false;
  #     #   # "toolkit.telemetry.server" = "data:,";
  #     #   # "toolkit.telemetry.archive.enabled" = false;
  #     #   # "toolkit.telemetry.coverage.opt-out" = true;
  #     #   #
  #     #   # # Disable crash reports
  #     #   # "breakpad.reportURL" = "";
  #     #   # "browser.tabs.crashReporting.sendReport" = false;
  #     #   # "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # don't submit backlogged reports
  #     #   # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  #     #   #
  #     #   # "browser.onboarding.enabled" = false;
  #     #   # # "browser.download.dir" = "${config.user.home}/Downloads";
  #     # };
  #     name = "default";
  #     isDefault = true;
  #     extensions = with pkgs.nur.repos.rycee.firefox-addons; [
  #       ublock-origin
  #       # bypass-paywalls-clean
  #       tridactyl
  #     ];
  #
  #     # userChrome = ''
  #     #   @import "${
  #     #     builtins.fetchGit {
  #     #       url = "https://github.com/rockofox/firefox-minima";
  #     #       ref = "main";
  #     #       rev = "976564bbbab3df0deafcba3e6e9f73ca7ad3b4ad"; # <-- Change this
  #     #     }
  #     #   }/userChrome.css";
  #     # '';
  #
  #     userChrome = builtins.readFile ./pkgs/firefox/userChrome.css;
  #   };
  # };
}
