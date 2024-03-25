{
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "kyungrok.chung";

  home.file."${config.xdg.configHome}/ghostty/config".text = ''
window-decoration = false
macos-option-as-alt = true
adjust-cell-width = -1

window-padding-x = 0
window-padding-y = 0

keybind = ctrl+comma=reload_config
keybind = ctrl+equal=increase_font_size:1
keybind = ctrl+minus=decrease_font_size:1
keybind = ctrl+shift+v=paste_from_clipboard

font-family	= Iosevka Term Slab Light

palette = 0=#4f4f4f
palette = 1=#fa6c60
palette = 2=#a8ff60
palette = 3=#fffeb7
palette = 4=#96cafe
palette = 5=#fa73fd
palette = 6=#c6c5fe
palette = 7=#efedef
palette = 8=#7b7b7b
palette = 9=#fcb6b0
palette = 10=#cfffab
palette = 11=#ffffcc
palette = 12=#b5dcff
palette = 13=#fb9cfe
palette = 14=#e0e0fe
palette = 15=#ffffff
background = 000000
foreground = f1f1f1
cursor-color = 808080
selection-background = b5d5ff
selection-foreground = 000000
'' + (
if stdenv.isDarwin then ''
    enable = true;
    windowManager.i3.enable = true;
'' else ''''
  );

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
    # package = pkgs.firefox-devedition-bin;
    package = pkgs.firefox-devedition-bin;
    # package = pkgs.wrapFirefox pkgs.firefox-devedition-bin {
    #     extraPolicies = {
    #           DisableAppUpdate = true;
    #           ManualAppUpdateOnly = true;
    #           DisablePocket = true;
    #           DisableSetDesktopBackground = true;
    #           DisableTelemetry = true;
    #     };
    # };

    policies = {
          DisableAppUpdate = true;
          ManualAppUpdateOnly = true;
          DisablePocket = true;
          DisableSetDesktopBackground = true;
          DisableTelemetry = true;
    };
    profiles.default = {
      id = 0;
      settings = {
        "app.update.auto" = false;
        "app.update.checkInstallTime" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.aboutConfig.showWarning" = false;
        "browser.warnOnQuit" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "app.update.interval" = 2592000;
        "extensions.pocket.enabled" = false;

        # "browser.urlbar.placeholderName" = "Google";
        # "app.update.auto" = false;
        # "browser.startup.page" = 3; # Restore previous session
        #
        # "browser.newtabpage.enabled" = false;
        # "browser.newtab.url" = "about:blank";
        #
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
        bypass-paywalls-clean
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
