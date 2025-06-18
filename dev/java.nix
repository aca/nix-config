{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kotlin
    kotlin-language-server
    # openjdk
    # jetbrains.idea-community-bin
  ];
}
