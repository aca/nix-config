{
  config,
  pkgs,
  ...
}: {
  systemd.timers."errtest" = {
    wantedBy = ["timers.target"];
    enable = true;
    timerConfig = {
      # OnBootSec = "10m";
      OnUnitActiveSec = "5m";
      Unit = "errtest.service";
    };
  };

  systemd.services."errtest" = {
    script = with pkgs; ''
      set -euxo pipefail
      echo "start"
      sleep 30
      echo "fail 1"
      exit 1
    '';
  };
}
