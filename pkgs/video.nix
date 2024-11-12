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
    pkgs.ffmpeg_7-full
    pkgs.mpv-unwrapped
  ];
}
