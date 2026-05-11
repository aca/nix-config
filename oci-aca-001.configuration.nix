{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # module_files = ../modules/ |>                      # assign the result of the pipe to module_files, & pass ../modules/ to the function on the next line
  #   builtins.b.readDir |>                                     # returns an attribute set, names are files, values their type
  #   builtins.b.attrNames |>                                   # gets the names of the attribute set, the files
  #   builtins.b.filter (f: lib.strings.hasSuffix ".nix" f) |>  # keep only files that end in ".nix"
  #   builtins.b.map (e: ../oci-aca-001.batch/${e});                      # for each file prepend the path to the directory
  module_files = builtins.map (e: ./oci-aca-001.batch/${e}) (
    builtins.filter (f: lib.strings.hasSuffix ".nix" f) (
      builtins.attrNames (builtins.readDir ./oci-aca-001.batch)
    )
  );

  boot.kernelPackages = pkgs.linuxPackages_latest; # use latest kernel

  home.enableNixpkgsReleaseCheck = false;

  xytDomain =
    "xyt.xk"
    +
      # hsdomain
      "or.stream";

  nbDomain =
    "nb.xk"
    +
      # hsdomain
      "or.stream";

  hsDomain =
    "hs.xk"
    +
      # hsdomain
      "or.stream";

  secrets = builtins.exec [
    # -i /etc/ssh/ssh_host_ed25519_key
    "age"
    "--decrypt"
    # "-i"
    # "/etc/ssh/ssh_host_ed25519_key"
    "-i"
    "/home/rok/.ssh/id_ed25519"
    ./secrets/oci-aca-001.nix.age
    # "age" "--decrypt" "-i" "/etc/ssh/ssh_host_ed25519_key" "-i" "/root/.ssh/id_ed25519" ./secrets/oci-aca-001.nix.age
    # "bash"
    # "-c"
    # "age --decrypt -i /home/rok/.ssh/id_ed25519 ./secrets/oci-aca-001.nix.age"
  ];
in
{
  imports = [
    ./hardware/oci-aca-001.nix
    # ./internal.matrix.nix
    ./pkgs/xrdp.nix
    ./ntfy.nix
    ./pkgs/enlightment.nix
    ./linux.configuration.nix
    ./vector/vector-systemd.nix
    ./oci-aca-001.app.nix
    ./internal.ntfy.nix
    ./pkgs/archive-downloads.nix
  ]
  ++ module_files;

  "internal.ntfy".baseUrl = "https://ntfy.${secrets.INTERNAL_BASEURL}";
  "internal.ntfy".port = 119;

  # curl -N http://oci-aca-001:9428/select/logsql/tail -d 'query=*'
  # curl 'http://oci-aca-001:9428/internal/force_flush'
  services.victorialogs.enable = true;
  services.victorialogs.extraOptions = [
    "-retentionPeriod=7d"
  ];

  # services.zerotierone = {
  #   enable = true;
  #   joinNetworks = [
  #     "68bea79acfa612d0"
  #   ];
  # };

  # increase burst limit
  services.journald.rateLimitInterval = "10s";
  services.journald.rateLimitBurst = 20000;

  services.ttyd.enable = true;
  services.ttyd.port = 2119;
  services.ttyd.writeable = true;

  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  # services.loki = {
  #   enable = true;
  #   configFile = pkgs.writeText "loki-config.yaml" ''
  #     auth_enabled: false
  #
  #     server:
  #       http_listen_port: 3100
  #       log_level: error
  #
  #     common:
  #       ring:
  #         instance_addr: 127.0.0.1
  #         kvstore:
  #           store: inmemory
  #       replication_factor: 1
  #       path_prefix: /tmp/loki
  #
  #     schema_config:
  #       configs:
  #       - from: 2020-05-15
  #         store: tsdb
  #         object_store: filesystem
  #         schema: v13
  #         index:
  #           prefix: index_
  #           period: 24h
  #
  #     storage_config:
  #       filesystem:
  #         directory: /tmp/loki/chunks
  #   '';
  # };

  # services.grafana = {
  #   enable = true;
  #   settings = {
  #     server = {
  #       http_addr = "0.0.0.0";
  #       http_port = 3000;
  #       serve_from_sub_path = true;
  #     };
  #     security.admin_pasword = "admin";
  #   };
  #   provision.enable = true;
  #   provision.datasources.settings = {
  #     datasources = [
  #       {
  #         name = "loki";
  #         type = "loki";
  #         access = "proxy";
  #         url = "http://127.0.0.1:3100";
  #         isDefault = false;
  #       }
  #       {
  #         name = "prometheus";
  #         type = "prometheus";
  #         access = "proxy";
  #         url = "http://127.0.0.1:9090";
  #         isDefault = false;
  #       }
  #     ];
  #   };
  # };

  # services.prometheus = {
  #   enable = true;
  #   # port = 9001;
  #   scrapeConfigs = [
  #     {
  #       job_name = "seedbox.node-exporter";
  #       static_configs = [
  #         {
  #           targets = [ "seedbox:9000" ];
  #           labels = {
  #             node = "seedbox";
  #           };
  #         }
  #       ];
  #     }
  #
  #     {
  #       job_name = "asset";
  #       static_configs = [
  #         {
  #           targets = [ "oci-aca-001:6000" ];
  #           # labels = {
  #           #   node = "seedbox";
  #           # };
  #         }
  #       ];
  #     }
  #   ];
  # };

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/rok/.ssh/id_ed25519"
  ];

  # services.matrix-synapse.settings.server_name = "matrix.${secrets.INTERNAL_BASEURL}";
  # services.matrix-synapse.settings.public_baseurl = "https://matrix.${secrets.INTERNAL_BASEURL}";
  # age.secrets."services.matrix-synapse.extraConfigFiles.registration_shared_secret" = {
  #   file = ./secrets/oci-aca-001/services.matrix-synapse.extraConfigFiles.registration_shared_secret.age;
  #   mode = "444";
  # };
  # services.matrix-synapse.extraConfigFiles = [
  #   config.age.secrets."services.matrix-synapse.extraConfigFiles.registration_shared_secret".path
  # ];

  # services.caddy.virtualHosts."matrix.${secrets.INTERNAL_BASEURL}".extraConfig = ''
  #   reverse_proxy http://localhost:8448
  # '';

  age.secrets."env" = {
    file = ./secrets/oci-aca-001/env.age;
    mode = "444";
  };
  environment.extraInit = "source ${config.age.secrets."env".path}";

  services.caddy.enable = true;

  # services.caddy.virtualHosts."ntfy.${secrets.INTERNAL_BASEURL}".extraConfig = ''
  #     log {
  #        output stdout
  #     }
  #   reverse_proxy http://localhost:119
  # '';

  # services.caddy.virtualHosts."xyt.${secrets.INTERNAL_BASEURL}".extraConfig = ''
  #     log {
  #        output stdout
  #     }
  #   reverse_proxy http://localhost:8282
  # '';

  services.caddy.virtualHosts.":80".extraConfig = ''
    reverse_proxy http://localhost:8080
  '';

  # services.grafana = {
  #   enable = true;
  #   settings = {
  #     server = {
  #       http_addr = "0.0.0.0";
  #       http_port = 3000;
  #       serve_from_sub_path = true;
  #     };
  #     security.admin_pasword = "admin";
  #   };
  # };

  system.stateVersion = "25.11";
  networking.hostName = "oci-aca-001";

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];
  services.tailscale.extraDaemonFlags = [ "--socks5-server=0.0.0.0:1080" ]; # blocked by firewall
  # services.k3s.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      X11DisplayOffset = 10;
      X11UseLocalhost = false;
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    (import ./keys.nix).seedbox
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];

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
  };

  zramSwap.enable = true;

  # required for DNAT to 127.0.0.1 from external interfaces. Without this, the kernel silently drops packets routed to loopback from non-loopback interfaces.
  boot.kernel.sysctl."net.ipv4.conf.all.route_localnet" = 1;

  networking.firewall = {
    enable = true;
    logRefusedConnections = true;
    allowedTCPPorts = [
      22
      80
      443
      9222
    ];

    # chrome remote debugging, tailscale 127.0.0.2 -> 127.0.0.1:9222
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp ! -s 127.0.0.0/8 --dport 9222 -j DNAT --to-destination 127.0.0.1:9222
      iptables -t nat -A OUTPUT -p tcp -d 127.0.0.2 --dport 9222 -j DNAT --to-destination 127.0.0.1:9222
    '';
    # allowedUDPPorts = [
    #   22
    #   80
    #   443
    # ];
  };

  # nixpkgs.config.permittedInsecurePackages = ["nodejs-16.20.1"];
  # age.secrets."github.com__aca__oci-aca-002.age".file = ./secrets/github.com__aca__oci-aca-002.age;
  # services.github-runners.aca__oci-arm-host-capacity__oci-aca-002_001 = {
  #   enable = true;
  #   url = ''https://github.com/aca/oci-arm-host-capacity'';
  #   tokenFile = config.age.secrets."github.com__aca__oci-aca-002.age".path;
  #   replace = true;
  #   extraLabels = ["nix"];
  #   extraPackages = with pkgs; [
  #     php82
  #     php82Packages.composer
  #   ];
  # };

  environment.systemPackages = with pkgs; [
    (pkgs.chromium.override {
      commandLineArgs = [
        # "--enable-features=WebContentsForceDark"
        "--enable-quic"
        "--enable-zero-copy"
        "--disable-features=DarkMode"
        "--ozone-platform=x11"
        # "--remote-allow-origins=*"
        "--remote-debugging-port=9222"
        "--user-data-dir=/home/rok/store/chromium.oci-aca-001"
        # NOTES: ozone-platform=wayland fcitx win+space not work
      ];
    })

    claude-code-bin
    bun

    fzf
    caddy
    dig
    sqlite-interactive
    elvish
    git
    jq
    psmisc
    xpra
    fd
    htop
    ripgrep
    gcc
    procps
    aria2
    ghq
    xsel
    fish
    go-nightly
    vim
    socat
    inetutils

    xorg.xinit
    xorg.xauth
    xorg.xorgserver
    xorg.xhost
  ];

  services.postgresql = {
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128 trust
      host  all all 100.0.0.0/8 trust
    '';
    enable = true;
    settings = {
      log_connections = true;
      max_connections = 200;
      shared_preload_libraries = [
        "timescaledb"
        "pg_rational"
      ];
    };

    extensions =
      ps: with ps; [
        timescaledb
        pg_rational
      ];
  };

  # containers."postgresql-asset" = {
  #   autoStart = true;
  #   privateNetwork = false;
  #   # hostAddress    = "0.0.0.0";
  #   # localAddress   = "0.0.0.0";
  #
  #   config =
  #     {
  #       config,
  #       pkgs,
  #       lib,
  #       ...
  #     }:
  #     {
  #       services.postgresql.enable = true;
  #       services.postgresql.enableTCPIP = true;
  #
  #       # (luajit.withPackages (p:
  #       #   with p; [
  #       #     stdlib
  #       #     luarocks
  #       #   ]))
  #
  #       services.postgresql.settings.shared_preload_libraries = [
  #         "timescaledb"
  #         "pg_rational"
  #       ];
  #       services.postgresql.extensions =
  #         ps: with ps; [
  #           timescaledb
  #           pg_rational
  #         ];
  #       services.postgresql.settings.port = 3030;
  #       services.postgresql.authentication = pkgs.lib.mkOverride 10 ''
  #         local all all trust
  #         host  all all 127.0.0.1/32 trust
  #         host  all all ::1/128 trust
  #         host  all all 100.0.0.0/8 trust
  #       '';
  #       services.postgresql.initialScript = pkgs.writeText "init-postgres.sql" ''
  #         CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
  #         CREATE EXTENSION IF NOT EXISTS pg_rational CASCADE;
  #       '';
  #       services.postgresql.ensureUsers = [
  #         { name = "rok"; }
  #       ];
  #     };
  # };

  # services.clickhouse.enable = true;

  # services.nebula.networks.rootnet = {
  #   enable = true;
  #   isLighthouse = true;
  #   cert = "/etc/nebula/lighthouse.crt"; # The name of this lighthouse is beacon.
  #   key = "/etc/nebula/lighthouse.key";
  #   ca = "/etc/nebula/ca.crt";
  #
  #   firewall = {
  #     outbound = [
  #       {
  #         port = "any";
  #         proto = "any";
  #         host = "any";
  #       }
  #     ];
  #     inbound = [
  #       {
  #         port = "any";
  #         proto = "any";
  #         host = "any";
  #       }
  #     ];
  #   };
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

  # services.vector.journaldAccess = true;
  # services.vector.enable = true;
  # services.vector.settings = builtins.fromTOML (builtins.readFile ./vector-logfmt.systemd.toml);

  # services.nfs.server.enable = true;
  # services.nfs.server.exports = ''
  #   / 100.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
  # '';

  services.caddy.virtualHosts."https://nb.${secrets.INTERNAL_BASEURL}".extraConfig = ''
    reverse_proxy :8448
  '';

  # services.caddy.virtualHosts."https://claude-ocr.internal".extraConfig = ''
  #   tls ${./certs/mkcert/internal.pem} ${./certs/mkcert/internal-key.pem}
  #   reverse_proxy localhost:4444
  # '';
}
