{
  config,
  pkgs,
  ...
}:
{
  systemd.timers."qbittorrent-mv" = {
    wantedBy = [ "timers.target" ];
    enable = true;
    timerConfig = {
      OnUnitActiveSec = "1m";
      Unit = "qbittorrent-mv.service";
    };
  };

  systemd.services."qbittorrent-mv" = {
    path = [
      pkgs.fd
      pkgs.rclone
      pkgs.elvish
    ];
    serviceConfig.WorkingDirectory = "/home/qbittorrent/Downloads";
    serviceConfig.ExecStart =
      let
        script = pkgs.writeScript "qbittorrent-mv" ''
          #!${pkgs.elvish}/bin/elvish
          fd -I --hidden --type f --exclude '*.crdownload' | each { |x| 
            /run/current-system/sw/bin/timeout 12h --webdav-vendor=rclone --webdav-url='http://archive-0:5005' move --no-check-dest --checksum $x webdav:/$x
          }
        '';
      in
      "${script}";
  };
}
