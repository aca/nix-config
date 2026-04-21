{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.samba.enable = true;
  services.samba.openFirewall = true;
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.samba.settings = {
    tmp = {
      path = "/mnt/tmp";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "root";
      "force group" = "root";
    };
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
