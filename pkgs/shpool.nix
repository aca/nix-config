{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}:
{
  systemd.services."shpool" = {
    description = "Shpool - Shell Session Pool";
    wantedBy = [ "default.target" ];
    requires = [ "shpool.socket" ];
    serviceConfig = {
      User = "rok";
      Type = "simple";
      ExecStart = "${pkgs.shpool}/bin/shpool daemon";
      KillMode = "mixed";
      TimeoutStopSec = "2s";
      SendSIGHUP = true;
    };
  };

  systemd.sockets."shpool" = {
    description = "Shpool Shell Session Pooler";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "%t/shpool/shpool.socket" ];
    socketConfig = {
      User = "rok";
      SocketMode = "0600";
    };
  };
}
