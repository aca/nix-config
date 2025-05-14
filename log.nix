{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}: {
  services.vector.journaldAccess = true;
  services.vector.enable = true;
  services.vector.settings = builtins.fromTOML (builtins.readFile ./vector.toml);
}
