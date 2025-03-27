{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}: {
  systemd.tmpfiles.settings."logs" = {
    "/logs" = {d.mode = "0777";};
    "/logs/active" = {d.mode = "0777";};
  };
  services.vector.journaldAccess = true;
  services.vector.enable = true;
  services.vector.settings = builtins.fromTOML (builtins.readFile ./vector.toml);
}
