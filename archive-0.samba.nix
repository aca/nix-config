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
  services.samba.openFirewall = use_samba;
  services.samba-wsdd = {
    enable = use_samba;
    openFirewall = use_samba;
  };
  services.samba = {
    enable = use_samba;
    securityType = "user";
    # extraConfig = ''
    #   workgroup = WORKGROUP
    #   server string = archive-0
    #   netbios name = archive-0
    #   security = user
    #   #use sendfile = yes
    #   #max protocol = smb2
    #   # note: localhost is the ipv6 localhost ::1
    #   hosts allow = 0.0.0.0/0
    #   guest account = nobody
    #   map to guest = bad user
    # '';
    shares = {
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
      shared = {
        path = "/mnt/archive-0/shared";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "root";
        "force group" = "root";
      };
    };
  };
}
