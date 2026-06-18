{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}: {
  environment.systemPackages = [
    # pkgs.ffmpeg-full
    pkgs.wine-wayland
  ];
}
