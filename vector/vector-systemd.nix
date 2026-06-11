{
  config,
  pkgs,
  lib,
  ...
}:
let
  configFile = ./vector-systemd.toml;
  dataDir = "/var/lib/vector-systemd";
in
{
  environment.systemPackages = with pkgs; [
    vector
  ];
  systemd.services.vector-systemd = {
    description = "Vector (systemd journald shipper)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.vector}/bin/vector --config ${configFile}";
      Restart = "on-failure";
      RestartSec = "5s";
      StateDirectory = "vector-systemd";
      WorkingDirectory = dataDir;
      DynamicUser = true;
      SupplementaryGroups = [ "systemd-journal" ];

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
