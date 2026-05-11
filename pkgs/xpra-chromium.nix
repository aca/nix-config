{
  config,
  pkgs,
  lib,
  ...
}:
{
  systemd.services."xpra-chromium" = {
    enable = true;
    serviceConfig = {
      User = "rok";
    };
    script = "${pkgs.xpra}/bin/xpra start :100 --start=${pkgs.chromium}/bin/chromium --daemon=no";
    wantedBy = [ "network-online.target" ];
  };
};
