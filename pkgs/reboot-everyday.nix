{
  config,
  pkgs,
  ...
}: {
  systemd.timers."reboot-everyday" = {
    wantedBy = ["timers.target"];
    enable = true;
    timerConfig = {
      OnCalendar = "*-*-* 12:00:00";
      Unit = "reboot-everyday.service";
    };
  };

  systemd.services."reboot-everyday" = {
    script = with pkgs; ''
      set -euxo pipefail
      systemctl --force reboot
    '';
  };
}
