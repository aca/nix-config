{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    android
    android-tools
    android-studio
    android-udev-rules
    flutter
    jdk11
  ];
}
