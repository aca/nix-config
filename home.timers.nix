{
  config,
  pkgs,
  options,
  inputs,
  nix,
  lib,
  ...
}:
{
  systemd.timers.stop-zerotierone = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 23:30";  # 매일 23:30
      Persistent = true;
    };
  };

  systemd.services.stop-zerotierone = {
    description = "Stop ZeroTier One service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "systemctl stop zerotierone.service";
    };
  };

  systemd.timers.start-zerotierone = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon..Thu 10:00";  # 월-목 10:00
      Persistent = true;
    };
  };

  systemd.services.start-zerotierone = {
    description = "Start ZeroTier One service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "systemctl start zerotierone.service";
    };
  };
}
