{
  config,
  inputs,
  pkgs,
  ...
}:
let
  secrets = builtins.exec [
    "age"
    "--decrypt"
    "-i" "/etc/ssh/ssh_host_ed25519_key"
    ./secrets/oci-aca-001.nix.age
  ];
in
{
  imports = [
    ./hardware/oci-aca-001.nix
    ./internal.matrix.nix
    ./internal.ntfy.nix
  ];

  "internal.ntfy".baseUrl = "https://ntfy.${secrets.INTERNAL_BASEURL}";
  "internal.ntfy".port = 2556;

  # services.alloy = {
  #   enable = true;
  # };

  services.loki = {
    enable = true;
    configFile = pkgs.writeText "loki-config.yaml" ''
      auth_enabled: false

      server:
        http_listen_port: 3100
        log_level: error

      common:
        ring:
          instance_addr: 127.0.0.1
          kvstore:
            store: inmemory
        replication_factor: 1
        path_prefix: /tmp/loki

      schema_config:
        configs:
        - from: 2020-05-15
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: index_
            period: 24h

      storage_config:
        filesystem:
          directory: /tmp/loki/chunks
    '';
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        # http_port = 3000;
        serve_from_sub_path = true;
      };
      security.admin_pasword = "admin";
    };
    provision.enable = true;
    provision.datasources.settings = {
      datasources = [
        {
          name = "loki";
          type = "loki";
          access = "proxy";
          url = "http://127.0.0.1:3100";
          isDefault = false;
        }
        {
          name = "prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090";
          isDefault = false;
        }
      ];
    };
  };

  services.prometheus = {
    enable = true;
    # port = 9001;
    scrapeConfigs = [
      {
        job_name = "seedbox.node-exporter";
        static_configs = [
          {
            targets = [ "seedbox:9000" ];
            labels = {
              node = "seedbox";
            };
          }
        ];
      }
    ];
  };

  services.logind.lidSwitch = "ignore";

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  services.matrix-synapse.settings.server_name = "matrix.${secrets.INTERNAL_BASEURL}";
  services.matrix-synapse.settings.public_baseurl = "https://matrix.${secrets.INTERNAL_BASEURL}";

  age.secrets."services.matrix-synapse.extraConfigFiles.registration_shared_secret" = {
    file = ./secrets/oci-aca-001/services.matrix-synapse.extraConfigFiles.registration_shared_secret.age;
    mode = "444";
  };

  services.matrix-synapse.extraConfigFiles = [
    config.age.secrets."services.matrix-synapse.extraConfigFiles.registration_shared_secret".path
  ];

  services.caddy.enable = true;

  services.caddy.virtualHosts."matrix.${secrets.INTERNAL_BASEURL}".extraConfig = ''
    reverse_proxy http://localhost:8448
  '';

  services.caddy.virtualHosts."ntfy.${secrets.INTERNAL_BASEURL}".extraConfig = ''
    reverse_proxy http://localhost:2556
  '';

  # age.identityPaths = ["/root/.ssh/id_ed25519"];
  # services.caddy.virtualHosts.${(builtins.exec [ "age" "--decrypt" "-i" "/root/.ssh/id_ed25519" ./secrets/oci-aca-001.nix.age ]).matrix.host }.extraConfig = ''
  #   reverse_proxy http://localhost:8008
  # '';

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

  system.stateVersion = "25.05";
  networking.hostName = "oci-aca-001";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];
  services.tailscale.extraDaemonFlags = [ "--socks5-server=0.0.0.0:1080" ]; # blocked by firewall

  services.openssh.enable = true;
  # services.openssh.ports = [ ];
  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    (import ./keys.nix).seedbox
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
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

  zramSwap.enable = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
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

  # virtualisation.containers.enable = false;
  # virtualisation.containers.policy = {
  #   default = [{type = "insecureAcceptAnything";}];
  #   transports = {
  #     docker-daemon = {
  #       "" = [{type = "insecureAcceptAnything";}];
  #     };
  #   };
  # };

  # virtualisation.docker = {
  #   enable = false; # replace with podman
  #   # package = pkgs.docker;
  #   daemon.settings = {
  #     # hosts = ["tcp://127.0.0.1:2375"];
  #     hosts = ["tcp://0.0.0.0:2375"];
  #     # insecure-registries = import ./dev/docker.insecure-registries.nix;
  #   };
  # };

  environment.systemPackages = with pkgs; [
    fzf
    git
    jq
    fd
    htop
    ripgrep
    chromium
    gcc
    procps
    python3
    aria2
    elvish
    cargo
    ghq
    xsel
    fish
    go

    xorg.xinit
  ];

  # services.x2goserver.enable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";
}
