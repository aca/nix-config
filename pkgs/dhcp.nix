{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}:
{
  # services.kea.dhcp4 = {
  #   enable = true;
  #   settings = {
  #       interfaces-config = {
  #         interfaces = [ "enp2s0"];
  #       };
  #
  #   valid-lifetime = 4000;
  #   renew-timer =  1000;
  #   rebind-timer = 2000;
  #       lease-database = {
  #         type = "memfile";
  #         persist = true;
  #         name = "/var/lib/kea/dhcp4.leases";
  #       };
  #       subnet4 = [
  #         {
  #           id = 1;
  #           subnet = "192.168.2.0/24";
  #           pools = [{ pool = "192.168.2.100 - 192.168.2.200"; }];
  #           # option-data = [
  #           #   { name = "routers"; data = "192.168.1.2"; }
  #           #   # { name = "domain-name-servers"; data = "8.8.8.8, 1.1.1.1"; }
  #           # ];
  #         }
  #       ];
  #       # valid-lifetime = 3600;
  #       loggers = [
  #         {
  #           name = "kea-dhcp4";
  #           output_options = [{ output = "stdout"; }];
  #           severity = "INFO";
  #         }
  #       ];
  #     };
  # };
}
