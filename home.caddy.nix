{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
in
{
  services.caddy.enable = true;
  services.tailscale.permitCertUid = "caddy";
  services.caddy.logFormat = ''
    output stdout
    format json
    level DEBUG
  '';
}
