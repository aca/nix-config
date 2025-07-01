{
  config,
  pkgs,
  ...
}: rec {
  # pkgs.writeTextFile {
  #   name = "elvish-test2";
  #   text = ''
  #     #!${pkgs.elvish}/bin/elvish
  #     echo 3
  #   '';
  #   executable = true;
  #   destination = "/bin/my-file2";
  # }
  # systemd.timers."reboot-everyday" = {
  #   wantedBy = ["timers.target"];
  #   enable = true;
  #   timerConfig = {
  #     OnCalendar = "*-*-* 12:00:00";
  #     Unit = "reboot-everyday.service";
  #   };
  # };

  # systemd.services."xxx" = {
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig.Type = "oneshot";
  #   serviceConfig.User = "rok";
  #   path = [
  #       pkgs.qbittorrent-nox
  #       pkgs.which
  #   ];
  #   serviceConfig.ExecStart = let
  #     script = pkgs.writeScript "xxx" ''
  #       #!${pkgs.elvish}/bin/elvish
  #       echo 3333
  #       which qbittorrent-nox
  #       cd
  #       pwd
  #       whoami
  #       sleep 30
  #     '';
  #   in "${script} %u";
  # };

  # systemd.timers."qbittorrent-disk" = {
  #   wantedBy = ["timers.target"];
  #   enable = false;
  #   timerConfig = {
  #     OnBootSec = "3m";
  #     OnUnitActiveSec = "3m";
  #     Unit = "qbittorrent-reschedule.service";
  #   };
  # };
}
