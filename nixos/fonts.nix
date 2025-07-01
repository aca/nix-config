{
  config,
  pkgs,
  ...
}: {
  fonts.packages = with pkgs; [
    cm_unicode
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.iosevka-term-slab
    nanum
    source-code-pro
    ibm-plex
  ];
  # aria2c "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IosevkaTermSlab.zip"
  # ~/.local/share/fonts
  # fonts = {
  #   # enableDefaultPackages = true;
  #   packages = with pkgs; [
  #     noto-fonts
  #     noto-fonts-cjk
  #     noto-fonts-emoji
  #     # nerdfonts
  #     iosevka
  #     nanum
  #   ];
  #   # fontconfig = {
  #   #   defaultFonts = {
  #   #     serif = ["NanumGothic" "Noto Sans Mono"];
  #   #     sansSerif = ["NanumGothic" "Noto Sans Mono"];
  #   #     monospace = ["Noto Sans Mono"];
  #   #   };
  #   # };
  # };
}
