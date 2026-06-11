{
  config,
  pkgs,
  lib,
  ...
}:
let
  configFile = ./vector-alert.toml;
  dataDir = "/var/lib/vector-alert";
in
{
  environment.systemPackages = with pkgs; [
    vector
  ];
  systemd.services.vector-alert = {
    description = "Vector (alert forwarder to ntfy.sh)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.vector}/bin/vector --config ${configFile}";
      Restart = "on-failure";
      RestartSec = "5s";
      StateDirectory = "vector-alert";
      WorkingDirectory = dataDir;
      DynamicUser = true;

      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
    };
  };
}
