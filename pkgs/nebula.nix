{
  config,
  pkgs,
  ...
}:
{
  # services.nebula.networks.mesh = {
  #   enable = true;
  #   isLighthouse = true;
  #   staticHostMap = {
  #       "192.168.100.1" = [
  #       ];
  #   };
  #   cert = "/etc/nebula/home.crt";
  #   key = "/etc/nebula/home.key";
  #   ca = "/etc/nebula/ca.crt";
  # };

  # services.nebula.networks.rootnet = {
  #   enable = true;
  #   isLighthouse = false;
  #   settings = {
  #     lighthouse = {
  #       hosts = [ "192.168.200.1" ];
  #     };
  #   };
  #   staticHostMap = {
  #     "192.168.200.1" = [
  #       "152.67.199.70:4242"
  #     ];
  #   };
  #
  #   firewall = {
  #     outbound = [
  #       {
  #         port = "any";
  #         proto = "any";
  #         host = "any";
  #       }
  #     ];
  #     inbound = [
  #       {
  #         port = "any";
  #         proto = "any";
  #         host = "any";
  #       }
  #     ];
  #   };
  #
  #   cert = "/etc/nebula/home.crt"; # The name of this lighthouse is beacon.
  #   key = "/etc/nebula/home.key";
  #   ca = "/etc/nebula/ca.crt";
  # };
}
