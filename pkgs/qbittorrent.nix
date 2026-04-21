{
  config,
  pkgs,
  lib,
  ...
}:
rec {
  services.qbittorrent.user = "rok";
  services.qbittorrent.group = "qbittorrent";

  systemd.services.qbittorrent.serviceConfig.ProtectHome = lib.mkForce "false";
  services.qbittorrent.webuiPort = 8080;
  services.qbittorrent.enable = true;
  # services.qbittorrent.package = pkgs.qbittorrent-enhanced;
  services.qbittorrent.serverConfig = {
    BitTorrent = {
      Session = {
        AddExtensionToIncompleteFiles = true;
        AddTorrentToTopOfQueue = true;
        AddTorrentStopped = true;
        QueueingSystemEnabled = false;
        AddTrackersFromURLEnabled = true;
        TempPath = "/home/rok/tor";
        TempPathEnabled = true;
        TorrentExportDirectory = "/home/rok/tor.torrent";
        ResumeDataStorageType = "SQLite";
        TorrentStopCondition = "FilesChecked";
        AdditionalTrackersURL = "https://fastly.jsdelivr.net/gh/XIU2/TrackersListCollection/all.txt";
        DefaultSavePath = "/home/rok/Downloads";
        MaxUploads = 1;
        MaxUploadsPerTorrent = 1;

        uTPRateLimited = true;
        IgnoreLimitsOnLAN = true;
        IncludeOverheadInLimits = true;
        GlobalUPSpeedLimit = 500;
      };
    };
    AutoRun = {
      enabled = true;
      program = ''
        "/run/current-system/sw/bin/curl -d \"hashes=%I&deleteFiles=false\"  \"http://localhost:8080/api/v2/torrents/delete\""
      '';
      # program = "/run/current-system/sw/bin/curl -d 'hashes=%I' 'http://localhost:8080/api/v2/torrents/delete'";
    };
    Core = {
      AutoDeleteAddedTorrentFile = "Never";
    };
    Preferences = {
      WebUI = {
        AuthSubnetWhitelist = "100.0.0.0/8";
        AuthSubnetWhitelistEnabled = true;
        LocalHostAuth = false;
      };
      Advanced = {
        RecheckOnCompletion = true;
      };
    };
  };
}
