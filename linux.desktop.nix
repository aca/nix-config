{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}:
let
in
{
  imports = [
    # ./env.nix
    # ./dev/default_ssh.nix
    # ./pkgs/scripts.nix
    # ./pkgs/tmux/tmux.nix
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # ubuntu_font_family
      noto-fonts
      # noto-fonts-cjk
      # comin
      # liberation_ttf
      # fira-code
      # fira-code-symbols
      # mplus-outline-fonts.githubRelease
      # nerdfonts
      iosevka
      # iosevka-comfy.comfy
      # iosevka-comfy.comfy-duo
      # iosevka-comfy.comfy-fixed
      # iosevka-comfy.comfy-motion
      # dina-font
      # sarasa-gothic
      nanum
      # office-code-pro
      source-code-pro
      # (nerdfonts.override { fonts = [ "source-code-pro" ]; })
      # proggyfonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        sansSerif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        monospace = [
          "NanumGothicCoding"
          "Noto Sans Mono"
        ];
      };
    };
  };

  environment.systemPackages = [
    pkgs.element-desktop
    pkgs.zathura
    pkgs.elvish
  ];

  # sudo 로그 비활성화
  security.sudo.extraConfig = ''
    Defaults !syslog
    Defaults !logfile
  '';

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # i18n = {
  #   defaultLocale = "en_US.UTF-8";
  #   inputMethod = {
  #     enable = true;
  #     # type = "kime";
  #   };
  # };
}
