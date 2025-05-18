{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/seedbox.nix
    ./all.configuration.nix
  ];

  system.stateVersion = "24.11";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "seedbox";

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];
  # services.tailscale.extraDaemonFlags = ["--socks5-server=100.95.211.5:1080"]; # blocked by firewall
  services.tailscale.extraDaemonFlags = [ "--socks5-server=0.0.0.0:1080" ]; # blocked by firewall

  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.enable = true;

  services.openssh.ports = [ 22 ]; # tailscale will use port 22
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  zramSwap.enable = true;

  services.prometheus.exporters.node = {
    enable = true;
    port = 9000;
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
    # enabledCollectors = [ "systemd" ];
    extraFlags = [
      "--collector.ethtool"
      "--collector.softirqs"
      "--collector.tcpstat"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
      # 5022
    ];
  };

  environment.systemPackages = with pkgs; [
    fzf
    git
    tmux
    jq
    gcc
    go
    postgresql
    nfs-utils
    fd
    htop
    just
    inetutils
    shpool
    aria2
    elvish
    vifm
    wget
    coreutils-full
    bun
    gopls
    moreutils
    iftop
    glances
    glibcLocales
    ghq
    stow
    gnumake
    entr
    procps
    vim
    psmisc
    zsh
    fish
    xsel
  ];

  services.caddy.enable = true;
  services.caddy.virtualHosts."torrent.internal".extraConfig = ''
    reverse_proxy http://localhost:8080
    tls ${./certs/mkcert/internal.pem} ${./certs/mkcert/internal-key.pem}
  '';

  users.users.qbittorrent-nox = {
    isNormalUser = true;
    homeMode = "777";
    linger = true;
    extraGroups = [
    ];
  };

  fileSystems."/mnt/tmp" = {
    device = "100.100.82.59:/mnt/tmp";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      # "x-systemd.requires=network-online.target"
    ];
  };

  # /run/current-system/sw/bin/curl --data "hashes=%I" "http://100.115.251.37:8080/api/v2/torrents/stop"
  systemd.services."qbittorrent-nox" = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      User = "qbittorrent-nox";
    };
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /home/qbittorrent-nox   100.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
  '';

  # services.prometheus = {
  #   exporters = {
  #     node = {
  #       enable = true;
  #       # enabledCollectors = ["systemd"];
  #       port = 9100;
  #       listenAddress = "0.0.0.0";
  #     };
  #   };
  # };

  # # curl 100.79.222.108:9100/prometheus
  # services.prometheus = {
  #   exporters = {
  #     node = {
  #       enable = true;
  #       enabledCollectors = ["systemd"];
  #       port = 9100;
  #       listenAddress = "100.79.222.108";
  #     };
  #   };
  # };

  # age.identityPaths = ["/root/.ssh/id_ed25519"];
  # age.secrets."github.com__aca".file = ./secrets/github.com__aca.age;
  # services.github-runner = {
  #   enable = true;
  #   url = ''https://github.com/aca-x'';
  #   # tokenFile = ''/root/.github'';
  #   #
  #   tokenFile = config.age.secrets."github.com__aca".path;
  #   name = ''aca-x_oci-xnzm-001_001'';
  #   replace = true;
  #   extraLabels = ["nix"];
  #   extraPackages = with pkgs; [
  #     # php82
  #     # php82Packages.composer
  #   ];
  # };

  containers."81r" = {
    autoStart = true;
    privateNetwork = false;
    # hostAddress    = "0.0.0.0";
    # localAddress   = "0.0.0.0";

    config =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        services.postgresql.enable = true;
        services.postgresql.enableTCPIP = true;
        services.postgresql.package = pkgs.postgresql;
        services.postgresql.settings.port = 5418;
        services.postgresql.authentication = pkgs.lib.mkOverride 10 ''
          local all       all     trust
          host  all       all      100.0.0.0/8   trust
        '';
        services.postgresql.ensureUsers = [
          { name = "rok"; }
        ];
        # networking.firewall.allowedTCPPorts = [ 5418 ];
        # system.stateVersion = "24.11";
        # services.postgresql.enable = true;
        # services.postgresql.package = pkgs.postgresql_15;
        # networking.firewall.enable = true;
      };
  };

  # systemd.services."shpool" = {
  #   description = "Shpool - Shell Session Pool";
  #   wantedBy = [ "default.target" ];
  #   requires = [ "shpool.socket" ];
  #   serviceConfig = {
  #     User = "root";
  #     Type = "simple";
  #     ExecStart = "${pkgs.shpool}/bin/shpool daemon";
  #     KillMode = "mixed";
  #     TimeoutStopSec = "2s";
  #     SendSIGHUP = true;
  #   };
  # };
  #
  # systemd.sockets."shpool" = {
  #   description = "Shpool Shell Session Pooler";
  #   wantedBy = [ "sockets.target" ];
  #   listenStreams = [ "%t/shpool/shpool.socket" ];
  #   socketConfig = {
  #     User = "root";
  #     SocketMode = "0600";
  #   };
  # };
  systemd.services.disk-monitor = {
    description = "Daemon to stop qbittorrent-nox if disk free < 5 GB";
    # after = [ "local-fs.target" "network.target" ];
    # wantedBy = [ "multi-user.target" ];

    # simple loop, restarted automatically if it ever dies
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 60; # 60 seconds between restarts
      ExecStart = ''
        ${pkgs.bash}/bin/bash -e -c '
                MOUNT="/"
                THRESHOLD=5
                while :; do
                  # df --output=avail gives KiB; -BG rounds to GB and prints e.g. "5G"
                  avail=$(df --output=avail -BG "$MOUNT" | tail -n1 | tr -dc "0-9")
                  if [ "$avail" -lt "$THRESHOLD" ]; then
                    systemctl stop qbittorrent-nox.service
                  fi
                  sleep 60
                done
      '';
    };
  };
}
