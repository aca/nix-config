{
  config,
  pkgs,
  ...
}:
{
  systemd.timers."archive-downloads" = {
    wantedBy = [ "timers.target" ];
    enable = true;
    timerConfig = {
      OnUnitActiveSec = "5m";
      OnActiveSec = "0s";
      Unit = "archive-downloads.service";
    };
  };

  systemd.services."archive-downloads" = {
    path = [
      pkgs.fd
      pkgs.rsync
      pkgs.findutils
      pkgs.bash
    ];

    # serviceConfig.WorkingDirectory = "/home/rok/Downloads";
    serviceConfig.ExecStart =
      let
        # fd -I --type f --threads=1 --exclude '*.crdownload' -x /run/current-system/sw/bin/timeout 12h rclone --webdav-vendor=rclone --webdav-url='http://archive-0:5005' move --no-check-dest --checksum "{}" ":webdav,webdav:/{}"
        # fd -I --type f --threads=1 --exclude '*.crdownload' -x rsync -avz --no-perms --relative -P --omit-dir-times --remove-source-files "{}" rsync://archive-0/tmp/
        script = pkgs.writeScript "archive-downloads" ''
          #!/usr/bin/env bash
          set -x
          cd /home/rok/Downloads || exit 0

          # cp with rsync to archive-0/tmp, except for tmp files, and files modified in the last 10 minutes
          find . -type f \
            ! -name '*.crdownload' \
            ! -name '*.!qB' \
            -amin +10 \
            -exec timeout 4h rsync -avz --no-perms --relative -P --omit-dir-times --remove-source-files {} rsync://archive-0/tmp/ \;

          # move encoded files to Downloads
          cd /mnt/archive-0 || exit 0
          fd --extension .av1.mp4 -x mv -v -n "{}" /home/rok/Downloads/
          
        '';
      in
      "${script}";
  };
}
