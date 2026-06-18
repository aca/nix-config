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
  services.grafana = {
    enable = true;
    settings.server.http_port = 9000;
    settings.server.http_addr = "0.0.0.0";
    settings.security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
  };

  systemd.services.grafana.serviceConfig.ProtectHome = lib.mkForce "false";
}
