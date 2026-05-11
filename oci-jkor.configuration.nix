{
  config,
  pkgs,
  ...
}:
{
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     python3 = prev.python312;
  #     python3Packages = prev.python312Packages;
  #   })
  # ];

  imports = [
    ./hardware/oci-jkor.nix
    ./pkgs/archive-downloads.nix
    ./pkgs/scripts.nix
    # ./pkgs/i3.nix
    # ./pkgs/qbittorrent-mv.nix
    # ./seedbox-impx.app.nix
  ];

  # services.victoriametrics.enable = true;
  # services.victoriametrics.extraOptions = [
  #   "-search.latencyOffset=0"
  # ];

  services.xrdp.enable = true;
  services.xrdp.openFirewall = true;
  # services.xrdp.defaultWindowManager = "/run/current-system/sw/bin/lxqt-session";
  services.xrdp.defaultWindowManager = "/run/current-system/sw/bin/enlightenment_start";
  services.xserver.enable = true;
  # services.xserver.desktopManager.lxqt.enable = true;
  # services.xserver.desktopManager.lxqt.enable = true;
  environment.enlightenment.excludePackages = [
    pkgs.enlightenment.econnman
  ];

  services.xserver.desktopManager.enlightenment.enable = true;
  # services.xserver.windowManager.twm.enable = true;

  # systemd.services."xpra-chromium" = {
  #   enable = true;
  #   serviceConfig = {
  #     User = "rok";
  #   };
  #   script = "${pkgs.xpra}/bin/xpra start :100 --start=/run/current-system/sw/bin/chromium --daemon=no";
  #   wantedBy = [ "network-online.target" ];
  # };

  # services.xserver.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "startplasma-x11";
  # services.xrdp.openFirewall = true;

  system.stateVersion = "25.11";
  # boot.kernelPackages = pkgs.linuxPackages_testing;
  networking.hostName = "oci-jkor";

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  # services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true" "--tun=userspace-networking" "--socks5-server=100.104.61.64:1080"];
  # services.tailscale.extraUpFlags = ["--ssh" "--advertise-exit-node=true" "--tun=userspace-networking" "--socks5-server=100.104.61.64:1080"];
  # services.tailscale.extraDaemonFlags = ["--tun=userspace-networking --socks5-server=100.104.61.64:1080"];
  services.tailscale.extraDaemonFlags = [
    "--socks5-server=0.0.0.0:1080"
    "-verbose=9"
  ]; # blocked by firewall
  # services.tailscale.interfaceName = "userspace-networking";

  # age.identityPaths = ["/home/rok/.ssh/id_ed25519"];

  # age.secrets."env" = {
  #   file = ./secrets/env.seedbox-impx.age;
  #   mode = "777";
  # };
  # environment.extraInit = "source ${config.age.secrets."env".path}";

  users.users.rok = {
    isNormalUser = true;
    description = "rok";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "adbusers"
      "libvirtd"
      "libvirt"
      "syncthing"
      "matrix-synapse"
      "cgit"
    ];
    openssh.authorizedKeys.keys = [
      (import ./keys.nix).root
      (import ./keys.nix).home
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    ];
  };

  services.dbus.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];

  zramSwap.enable = true;

  # services.prometheus.exporters.node = {
  #   enable = true;
  #   port = 9000;
  #   # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
  #   enabledCollectors = [ "systemd" ];
  #   extraFlags = [
  #     "--collector.ethtool"
  #     "--collector.softirqs"
  #     "--collector.tcpstat"
  #   ];
  # };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  services.vnstat.enable = true;
  environment.systemPackages = with pkgs; [
    fzf
    xpra
    rclone
    ffmpeg-full
    git
    tmux
    qbittorrent-enhanced-nox
    jq
    gcc
    go
    ripgrep
    fd
    duckdb
    sqlite-interactive
    just
    inetutils
    aria2
    ripgrep
    elvish
    vifm
    wget
    coreutils-full
    chromium
    moreutils
    glibcLocales
    ghq
    stow
    gnumake
    entr
    procps
    htop
    vim
    glances
    btop
    zsh
    fish
    xsel
    nebula

    pkgs.synadm
    pkgs.matrix-synapse
  ];

  # users.users.qbittorrent = {
  #   isNormalUser = true;
  #   homeMode = "777";
  #   linger = true;
  #   extraGroups = [
  #   ];
  # };

  # # /run/current-system/sw/bin/curl --data "hashes=%I" "http://100.115.251.37:8080/api/v2/torrents/stop"

  # systemd.services."qbittorrent" = {
  #   enable = true;
  #   serviceConfig = {
  #     ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
  #     User = "qbittorrent";
  #     # IOWriteBandwidthMax = "/dev/sda1 3M";  # 디스크 쓰기 10MB/s 제한
  #   };
  # };

  # services.webdav.enable = true;
  # services.webdav.settings = {
  #   address = "100.104.61.64";
  #   port = 8080;
  #   scope = "/dav";
  #   modify = true;
  #   auth = false;
  #   # users = [
  #   #   {
  #   #     username = "root";
  #   #     password = "toor";
  #   #   }
  #   # ];
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

  # fileSystems."/mnt/tmp" = {
  #   device = "100.100.82.59:/mnt/seedbox-impx";
  #   fsType = "nfs";
  #   # "x-systemd.device-timeout=10s"
  #   # x-systemd.automount
  #   # _netdev
  #   options = [
  #     "noatime"
  #     "nfsvers=3"
  #     # "x-systemd.requires=network-online.target"
  #   ];
  # };

  # systemd.services.qbitcheck = {
  #   description = "qbitcheck";
  #   enable = true;
  #   serviceConfig = {
  #     Type = "simple";
  #     Restart = "always";
  #     RestartSec = 60; # 60 seconds between restarts
  #     ExecStart = "${pkgs.writeShellScript "qbitcheck" ''
  #       /run/current-system/sw/bin/ping -i 15 100.100.82.59
  #     ''}";
  #   };
  # };

  # /run/current-system/sw/bin/curl --data "hashes=%I" "http://100.115.251.37:8080/api/v2/torrents/stop"
  systemd.services."qbittorrent" = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      User = "rok";
    };
  };

  services.matrix-synapse.enable = true;
  services.matrix-synapse.settings.database.name = "psycopg2";
  services.matrix-synapse.settings.enable_registration = false;
  services.matrix-synapse.enableRegistrationScript = true;

  security.sudo.extraRules = [
    {
      users = [ "rok" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];
  # services.matrix-synapse.settings.listeners = [
  #   {
  #     # bind_addresses = [
  #     #   "0.0.0.0"
  #     # ];
  #     # port = 8448;
  #     # resources = [
  #     #   {
  #     #     compress = true;
  #     #     names = [
  #     #       "client"
  #     #     ];
  #     #   }
  #     #   {
  #     #     compress = true;
  #     #     names = [
  #     #       "federation"
  #     #     ];
  #     #   }
  #     # ];
  #     tls = false;
  #     type = "http";
  #     x_forwarded = true;
  #   }
  # ];

  # systemd.services.postgresql.postStart = pkgs.lib.mkAfter ''
  #   $PSQL -tAc "SELECT 1 FROM pg_roles WHERE rolname = 'matrix-synapse'" | grep -q 1 || $PSQL -tAc "CREATE ROLE \"matrix-synapse\" WITH LOGIN"
  #   $PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = 'matrix-synapse'" | grep -q 1 || $PSQL -tAc "CREATE DATABASE \"matrix-synapse\" WITH OWNER \"matrix-synapse\" TEMPLATE template0 LC_COLLATE = 'C' LC_CTYPE = 'C'"
  # '';

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_17;

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
    # ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      { name = "rok"; }
      # {
      #   name = "matrix-synapse";
      #   ensureDBOwnership = true;
      # }
    ];
    settings.port = 5432;

    # initialScript = pkgs.writeText "init" ''
    #   CREATE ROLE "matrix-synapse";
    #   CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
    #     TEMPLATE template0
    #     LC_COLLATE = "C"
    #     LC_CTYPE = "C";
    #   ALTER ROLE "matrix-synapse" WITH LOGIN;
    # '';
  };

  systemd.services.postgresql-init-matrix = {
    description = "Initialize matrix-synapse database";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
    };
    script = ''
      ${config.services.postgresql.package}/bin/psql <<EOF
        DO \$\$
        BEGIN
          IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'matrix-synapse') THEN
            CREATE ROLE "matrix-synapse" WITH LOGIN;
          END IF;
        END
        \$\$;

        SELECT 'CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C"'
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'matrix-synapse')\gexec
      EOF
    '';
  };

  services.tailscale.permitCertUid = "caddy";
  services.caddy.enable = true;

  # services.caddy.virtualHosts."matrix.xkor.stream".extraConfig = ''
  #   reverse_proxy http://localhost:8008
  # '';

  age.secrets."services.matrix-synapse.extraConfigFiles.age" = {
    file = ./secrets/oci-jkor/services.matrix-synapse.extraConfigFiles.age;
    mode = "777";
  };
  services.matrix-synapse.extraConfigFiles = [
    config.age.secrets."services.matrix-synapse.extraConfigFiles.age".path

    (pkgs.writeText "rc" ''
      rc_login:
        address:
          per_second: 0.15
          burst_count: 5
        account:
          per_second: 0.18
          burst_count: 4
        failed_attempts:
          per_second: 0.19
          burst_count: 7
    '')
  ];
}
