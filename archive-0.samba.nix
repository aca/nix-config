{
  config,
  pkgs,
  lib,
  ...
}:
let
  use_samba = false;
in
{
  services.samba.enable = true;
  services.samba.openFirewall = use_samba;
  services.samba-wsdd = {
    enable = use_samba;
    openFirewall = use_samba;
  };
  services.samba.settings = {
    archive-0 = {
      path = "/mnt/archive-0";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "root";
      "force group" = "root";
    };
  };
}
