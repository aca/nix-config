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
      ${pkgs.unixtools.ping}/bin/ping -w10 -c1 -q google.com && exit 0
      sleep 60
      ${pkgs.unixtools.ping}/bin/ping -w10 -c1 google.com || systemctl reboot
    '';
  };
}
