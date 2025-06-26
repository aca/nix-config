{
  config,
  pkgs,
  ...
}: {
  systemd.timers."reboot-if-offline" = {
    wantedBy = ["timers.target"];
    enable = true;
    timerConfig = {
      OnBootSec = "30m";
      OnUnitActiveSec = "5m";
      Unit = "reboot-if-offline.service";
    };
  };

  systemd.services."reboot-if-offline" = {
    script = with pkgs; ''
      set -euxo pipefail
      ${pkgs.unixtools.ping}/bin/ping -w10 -c1 -q 1.1.1.1 && exit 0
      sleep 120
      ${pkgs.unixtools.ping}/bin/ping -w10 -c1 1.1.1.1 || systemctl reboot
    '';
  };
}
