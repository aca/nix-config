{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.xserver.enable = true;
  systemd.services."xpra-chromium" = {
    enable = true;
    serviceConfig = {
      User = "rok";
    };
    script = "${pkgs.xpra}/bin/xpra start :1000 --start=/run/current-system/sw/bin/chromium --daemon=no";
    wantedBy = [ "network-online.target" ];
  };
}
