{
  config,
  pkgs,
  ...
}:
{
  # /run/current-system/sw/bin/curl --data "hashes=%I" "http://100.115.251.37:8080/api/v2/torrents/stop"
  systemd.services."qbittorrent" = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      User = "rok";
    };
  };

}
