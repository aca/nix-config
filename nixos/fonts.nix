{
  config,
  pkgs,
  ...
}: {
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      nerdfonts
      iosevka
      nanum
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["NanumGothic" "Noto Sans Mono"];
        sansSerif = ["NanumGothic" "Noto Sans Mono"];
        monospace = ["Noto Sans Mono"];
      };
    };
  };
}
