{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}: {
  services.atuin.enable = true;
  environment.systemPackages = [
    pkgs.atuin
  ];
}
