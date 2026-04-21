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
  networking.wireless.iwd.enable = true;

  networking.networkmanager.enable = false;
  networking.useNetworkd = false;
  networking.useDHCP = false;

  networking.enableIPv6 = true;

  systemd.network.enable = true;
  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 1;
      dhcpV6Config.RouteMetric = 1;
      # domains = ["leo-rudd.ts.net"];
    };
    "20-wireless" = {
      matchConfig.Name = "wlan0";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 2;
      dhcpV6Config.RouteMetric = 2;
      # domains = ["leo-rudd.ts.net"];
    };
  };
}
