{
  config,
  pkgs,
  ...
}:
{
  systemd.services.disk-monitor = {
    description = "Daemon to stop qbittorrent-nox if disk free < 5 GB";
    # simple loop, restarted automatically if it ever dies

    script = '''';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 60; # 60 seconds between restarts
      ExecStart = "${pkgs.writeShellScript "disk-monitor" ''
        set -euo pipefail
        THRESHOLD=5
        while :; do
          for i in "/"; do
            avail=$(df --output=avail -BG "$i" | tail -n1 | tr -dc "0-9")
            echo "disk-monitor: available space on $i is $avail GB"
            if [ "$avail" -lt "$THRESHOLD" ]; then
              echo "disk-motion: stopping qbittorrent-nox.service due to low disk space on $i"
              systemctl stop qbittorrent-nox.service
            fi
          done
          sleep 60
        done
      ''}";
    };
  };
}
