{ pkgs, ... }:

{
  systemd.services.zt-txxx = {
    after = [ "zerotierone.service" ];
    requires = [ "zerotierone.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/current-system/sw" ];
    description = "zt-txxx";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      sleep 3
      /home/rok/src/git.internal/work/bin/zt-txxx.sh
    '';
  };
}
