{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  services.harmonia = {
    enable = true;
    signKeyPaths = [ "${inputs.internal}/seedbox-impx.harmonia.secret" ];
    settings = {
      bind = "[::]:5000";
    };
  };

  # networking.firewall.allowedTCPPorts = [ 5000 ];
}
