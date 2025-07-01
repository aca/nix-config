# httpr://nixos.org/guides/nix-pills/
{
  config,
  pkgs,
  options,
  inputs,
  nix,
  lib,
  ...
}@args:
let
  hostname = "home";
in
# secrets = builtins.extraBuiltins.readSops "/home/rok/.ssh/id_ed25519" ./secrets.json.age;
# secrets = builtins.extraBuiltins.readSops "werwrwer";
# secrets = "wer";
{
  programs.mosh.enable = true;
  programs.direnv = {
    # enable = true;
    nix-direnv.enable = true;
  };
  # services.nebula.networks.mesh = {
  #   enable = true;
  #   isLighthouse = false;
  #   # cert = "/etc/nebula/beacon.crt"; # The name of this lighthouse is beacon.
  #   # key = "/etc/nebula/beacon.key";
  #   # ca = "/etc/nebula/ca.crt";
  # };

  # services.nebula.networks.mesh = {
  #   enable = true;
  #   isLighthouse = true;
  #   staticHostMap = {
  #       "192.168.100.1" = [
  #       ];
  #   };
  #   cert = "/etc/nebula/home.crt";
  #   key = "/etc/nebula/home.key";
  #   ca = "/etc/nebula/ca.crt";
  # };

  # services.kea.dhcp4 = {
  #   enable = true;
  #   settings = {
  #       interfaces-config = {
  #         interfaces = [ "enp2s0"];
  #       };
  #
  #   valid-lifetime = 4000;
  #   renew-timer =  1000;
  #   rebind-timer = 2000;
  #       lease-database = {
  #         type = "memfile";
  #         persist = true;
  #         name = "/var/lib/kea/dhcp4.leases";
  #       };
  #       subnet4 = [
  #         {
  #           id = 1;
  #           subnet = "192.168.2.0/24";
  #           pools = [{ pool = "192.168.2.100 - 192.168.2.200"; }];
  #           # option-data = [
  #           #   { name = "routers"; data = "192.168.1.2"; }
  #           #   # { name = "domain-name-servers"; data = "8.8.8.8, 1.1.1.1"; }
  #           # ];
  #         }
  #       ];
  #       # valid-lifetime = 3600;
  #       loggers = [
  #         {
  #           name = "kea-dhcp4";
  #           output_options = [{ output = "stdout"; }];
  #           severity = "INFO";
  #         }
  #       ];
  #     };
  # };

  # programs.bash.vteIntegration = true;
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      X11DisplayOffset = 10;
      X11UseLocalhost = false;
    };
  };

  # security.auditd.enable = true;
  # services.journald.audit = true;

  environment.variables.ZK_ROOT = "/home/rok/src/git.internal/zk";

  age.secrets."hosts" = {
    file = ./secrets/hosts.age;
    mode = "777";
  };

  system.activationScripts."update-hosts" = ''
    cat /etc/hosts > /etc/hosts.bak
    rm /etc/hosts
    cat /etc/hosts.bak "${config.age.secrets."hosts".path}" >> /etc/hosts
  '';

  # system.activationScripts."experimental-features".text = ''
  #   mv /etc/nix/nix.conf /etc/nix/nix.conf.bak
  #   cat /etc/nix/nix.conf.bak > /etc/nix/nix.conf
  #   echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

  # networking.hosts = {
  #   "127.0.0.1" = ["localhost.internal" "home.internal" "git.internal"];
  # };

  # age.secrets."env.home" = { file = ./secrets/env.home.age; mode = "777"; };
  # environment.extraInit = "source ${config.age.secrets."env.home".path}";
  #
  # age.secretsDir = "/etc/agenix";
  # networking.hostFiles = [config.age.secrets."homelabhosts".path];
  # networking.hostFiles = [ "/etc/agenix/homelabhosts"];
  # networking.hostFiles = [
  # ./hosts
  # ];

  programs.nbd.enable = false;

  services.nginx.defaultHTTPListenPort = 4080;

  # networking.nameservers = [  "1.1.1.1" ];
  # # Enable Adguard Home and set bassic settigns
  # networking.nameservers = [ "127.0.0.1" ];
  networking.nameservers = [ "127.0.0.1" ];
  services.adguardhome = {
    enable = true;
    port = 4500;
    host = "127.0.0.1";
    settings = {
      dns = {
        bind_hosts = [
          "127.0.0.1"
        ];
      };
      # filtering = {
      #   rewrites = [
      #     {
      #       domain = "xxxxxxxxxxxxxxtest.com";
      #       answer = "192.168.50.20";
      #     }
      #   ];
      # };
    };
  };

  services.resolved = {
    enable = false;
    dnssec = "false";
    # domains = ["~."];
    # fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    # extraConfig = ''
    #   DNSOverTLS=yes
    # '';
    # extraConfig = ''
    #   DNSOverTLS=false
    # '';
  };

  services.cgit.home = {
    nginx.virtualHost = "git.home.internal";
    user = "rok";
    group = "users";
    enable = true;
    scanPath = "/home/rok/src/git.internal";
    settings = {
      enable-http-clone = 1;
    };
    extraConfig = ''
      robots=noindex, nofollow
      enable-index-owner=0
      branch-sort=age
      enable-http-clone=1
      enable-commit-graph=1
      clone-prefix=https://git.home.internal
    '';
  };

  # services.netbird.enable = true;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  # but NIX_PATH is still used by many useful tools, so we set it to the same value as the one used by this flake.
  # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
  # https://github.com/NixOS/nix/issues/9574
  nix.settings.nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";

  # nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.
  # nix.settings.nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
  networking.hostName = hostname;
  networking.wireless.iwd.enable = true;
  # networking.extraHosts = (import ./local.nix).networking.extraHosts;

  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  # age.secrets."github.com__aca" = {
  #   file = ./secrets/github.com__aca.age;
  #   mode = "777";
  # };
  # age.secrets.txxx = { file = ./secrets/txxx.age; path = "/etc/txxx"; mode = "777"; };
  # age.secrets."github.com__aca".file = ./secrets/github.com__aca.age;
  disabledModules = [ "services/networking/cgit.nix" ];

  age.secrets."env.home" = {
    file = ./secrets/env.home.age;
    mode = "777";
  };
  environment.extraInit = "source ${config.age.secrets."env.home".path}";

  # fileSystems."/mnt/rok-chatreey-t9/cache" = {
  #   device = "192.168.0.15:/mnt/rok-chatreey-t9/cache";
  #   fsType = "nfs";
  #   options = [
  #     "noatime"
  #     "x-systemd.requires=network-online.target"
  #   ];
  # };

  # fileSystems."/mnt/nas" = {
  #   device = "192.168.0.16:/volume1/root";
  #   fsType = "nfs";
  #   options = ["noatime" "x-systemd.requires=network-online.target"];
  # };

  fileSystems."/mnt/archive-0" = {
    device = "192.168.0.25:/mnt/archive-0";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      "x-systemd.requires=network-online.target"
    ];
  };

  # fileSystems."/mnt/data04" = {
  #   device = "192.168.0.2:/mnt/data04";
  #   fsType = "nfs";
  #   # "x-systemd.device-timeout=10s"
  #   # x-systemd.automount
  #   # _netdev
  #   options = ["noatime" "x-systemd.requires=network-online.target"];
  # };

  # services.atuin.enable = true;

  # pkgs.callPackage ./pkgs/scripts.nix { inherit hostName } ;

  imports = [
    ./seedbox-impx.app.nix

    ./configuration.nix
    ./desktop.linux.nix
    ./pkgs/cgit.nix
    ./pkgs/wine.nix
    ./dev/neovim_conf.nix
    ./workstation.nix
    ./networking.nix
    # ./pkgs/tailscale/modules.nix
    # "${inputs.nixpkgs-aca}/nixos/modules/services/networking/tailscale.nix"
    # ./pkgs/qbittorrent.nix

    # ./pkgs/scripts.nix
    # (import ./pkgs/scripts.nix {inherit hostname;})
    # ./pkgs/scripts.nix
    ./pkgs/video.nix
    ./pkgs/qBittorrent.nix
    ./pkgs/zapret.nix

    ./pkgs/sway/sway.nix

    # ./pkgs/nix-alien.nix

    ./dev/data.nix
    # ./dev/java.nix
    ./dev/default.nix
    ./dev/go.nix
    ./dev/container.nix
    ./dev/zig.nix
    ./dev/rust.nix
    ./dev/lua.nix
    ./dev/js.nix
    ./dev/python.nix
    ./dev/nix.nix

    ./pkgs/reboot-if-offline.nix
    # ./pkgs/systemd-x.nix
    # ./pkgs/reboot-everyday.nix

    ./hardware/home.nix
    # ./pkgs/jkor-matrix.nix
  ];

  systemd.services.rgit = {
    enable = true;
    # wantedBy = [ "multi-user.target" ];
    # wants = [ "network-online.target" ];
    # after = [ "network-online.target" ];
    path = [ pkgs.git ];
    script = ''
      ${pkgs.rgit}/bin/rgit --db-store /tmp/rgit.db 0.0.0.0:3333 /home/rok/src/git.internal
    '';
    serviceConfig = {
      Type = "exec";
      RestartSec = "5s";
      # ExecStart = "${pkgs.rgit}/bin/rgit --db-store /tmp/rgit.db 0.0.0.0:3333 /home/rok/src/git.internal";
      # Restart = "on-failure";

      User = "rok";
      Group = "users";

      # CapabilityBoundingSet = "";
      # NoNewPrivileges = true;
      # PrivateDevices = true;
      # PrivateTmp = true;
      # PrivateUsers = true;
      # PrivateMounts = true;
      # ProtectHome = true;
      # ProtectClock = true;
      # ProtectProc = "noaccess";
      # ProcSubset = "pid";
      # ProtectKernelLogs = true;
      # ProtectKernelModules = true;
      # ProtectKernelTunables = true;
      # ProtectControlGroups = true;
      # ProtectHostname = true;
      # RestrictSUIDSGID = true;
      # RestrictRealtime = true;
      # RestrictNamespaces = true;
      # LockPersonality = true;
      # RemoveIPC = true;
      # RestrictAddressFamilies = [
      #   "AF_INET"
      #   "AF_INET6"
      # ];
      # SystemCallFilter = [
      #   "@system-service"
      #   "~@privileged"
      # ];
    };
  };

  # services.grafana = {
  #   enable = true;
  #   settings.server.http_port = 9000;
  #   settings.server.http_addr = "127.0.0.1";
  # };

  # networking.firewall.allowedTCPPorts = [ 5418 ];
  # system.stateVersion = "25.05";
  # services.postgresql.enable = true;
  # services.postgresql.package = pkgs.postgresql_15;
  # networking.firewall.enable = true;

  systemd.services.grafana.serviceConfig.ProtectHome = lib.mkForce "false";

  # systemd.services.grafana.serviceConfig.ProtectSystem = lib.mkForce "false";
  # systemd.services.grafana.serviceConfig.PrivateUsers = lib.mkForce "false";
  # systemd.services.grafana.serviceConfig.PrivateTmp = lib.mkForce "false";
  # systemd.services.grafana.serviceConfig.ReadWritePaths = lib.mkForce "/home/rok";
  # systemd.services.grafana.serviceConfig.BindPaths = lib.mkForce "/home/rok";

  # systemd.services."gf" = {
  #   enable = true;
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     ProtectHome = "false";
  #     ProtectSystem = "false";
  #     PrivateUsers = "false";
  #     ReadWritePaths = "/home/rok";
  #     PrivateTmp = "false";
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/sqlite3 /home/rok/asset.db '.schema'
  #       /run/current-system/sw/bin/sleep 10000
  #     '';
  #   };
  # };

  services.tailscale.permitCertUid = "caddy";
  services.caddy.enable = true;

  services.caddy.virtualHosts."git.internal".extraConfig = ''
    reverse_proxy http://home:4080
    tls ${./certs/mkcert/internal.pem} ${./certs/mkcert/internal-key.pem}
  '';

  # services.caddy.virtualHosts.${(builtins.exec [ "age" "--decrypt" "-i" "/home/rok/.ssh/id_ed25519" ./xxx.age ]).a }.extraConfig = ''
  #   reverse_proxy http://home:4080
  #   tls ${./certs/mkcert/internal.pem} ${./certs/mkcert/internal-key.pem}
  # '';

  # services.caddy.virtualHosts.${(builtins.extraBuiltins.readSops ./secrets/var1.age)}.extraConfig = ''
  #   reverse_proxy http://xxx:4080
  #   tls ${./certs/mkcert/internal.pem} ${./certs/mkcert/internal-key.pem}
  # '';

  # systemd.services."ntfy" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       ${pkgs.ntfy-sh}/bin/ntfy serve -c /home/rok/src/root/ntfy/server.yml
  #     '';
  #   };
  # };

  # Doesn't work
  # systemd.services."ntfy" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       ${pkgs.ntfy-sh}/bin/ntfy serve -c /home/rok/src/root/ntfy/server.yml
  #     '';
  #   };
  # };

  # services.ntfy-sh = {
  #   enable = true;
  #   settings = {
  #     base-url = "https://jkor-ntfy.duckdns.org";
  #     listen-http = ":2555";
  #     behind-proxy = true;
  #     auth-default-access = "deny-all";
  #     # auth-file = "/home/rok/src/root/ntfy/user.db";
  #   };
  # };

  # attachment-cache-dir: /var/lib/ntfy-sh/attachments
  # auth-default-access: deny-all
  # auth-file: /var/lib/ntfy-sh/user.db
  # base-url: https://jkor-ntfy.duckdns.org
  # behind-proxy: true
  # cache-file: /var/lib/ntfy-sh/cache-file.db
  # listen-http: :2555

  programs.adb.enable = true;
  programs.fish.enable = true;

  services.udev.packages = with pkgs; [
    via
    vial
  ];
  # KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  # services.udev.extraRules = ''
  #   KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  # '';

  # NOTES: When public wifi doesn't work, comment all dns config and use default dns configuration on network
  # networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

  # config.networking.search = [
  # ];

  # services.dnsmasq = {
  #     enable = true;
  #     settings = {
  #       cname=["torrent.seedbox,seedbox.leo-rudd.ts.net"];
  #       address=[
  #           "/seedbox.leo-rudd.ts.net/100.87.185.91"
  #           "/example.cc/127.0.0.1"
  #       ];
  #       dns-forward-max=2;
  #       # server=["/*/127.0.0.1"];
  #       listen-address="127.0.0.113";
  #       bind-interfaces = true;
  #       no-resolv = true;
  #     };
  # };

  #   services.resolved = {
  #     enable = true;
  #     fallbackDns = [ "127.0.0.113" ];
  #     extraConfig = ''
  # [Resolve]
  # DNS=127.0.0.113
  # Domains=~seedbox
  # [Resolve]
  # DNS=127.0.0.114
  # Domains=~rok-chatreey-t8
  # [Resolve]
  # DNS=127.0.0.115
  # Domains=~rok-chatreey-t7
  #     '';
  #   };

  # Domains=~seedbox ~home

  # systemd.services."testhome" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /bin/sh -c "pwd; ls /home/rok/tmp; echo xxx > /home/rok/tmp/xxxxxx; sleep 1000"
  #     '';
  #   };
  # };
  #

  # systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  # systemd.timers = {
  #   "reboot-network-off" = {
  #     wantedBy = ["timers.target"];
  #     enable = true;
  #     timerConfig = {
  #       OnBootSec = "10m";
  #       OnUnitActiveSec = "10m";
  #       Unit = "qbittorrent-reschedule.service";
  #     };
  #   }
  # }
  #

  # systemd.services.printenv-rok = {
  #   enable = true;
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "rok";
  #     ExecStart = "/run/current-system/sw/bin/env";
  #   };
  # };

  systemd.services.printenv-root = {
    # Dec 18 22:20:17 home systemd[1]: Starting printenv-root.service...
    # Dec 18 22:20:17 home env[2006845]: LANG=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_ADDRESS=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_IDENTIFICATION=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_MEASUREMENT=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_MONETARY=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_NAME=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_NUMERIC=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_PAPER=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_TELEPHONE=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: LC_TIME=en_US.UTF-8
    # Dec 18 22:20:17 home env[2006845]: PATH=/nix/store/b1wvkjx96i3s7wblz38ya0zr8i93zbc5-coreutils-9.5/bin:/nix/store/w8pnfazxqwmrqmwkb5zrz1>
    # Dec 18 22:20:17 home env[2006845]: USER=root
    # Dec 18 22:20:17 home env[2006845]: INVOCATION_ID=21c90e6723144ce29e8a34c61686784f
    # Dec 18 22:20:17 home env[2006845]: JOURNAL_STREAM=9:12831253
    # Dec 18 22:20:17 home env[2006845]: SYSTEMD_EXEC_PID=2006845
    # Dec 18 22:20:17 home env[2006845]: MEMORY_PRESSURE_WATCH=/sys/fs/cgroup/system.slice/printenv-root.service/memory.pressure
    # Dec 18 22:20:17 home env[2006845]: MEMORY_PRESSURE_WRITE=c29tZSAyMDAwMDAgMjAwMDAwMAA=
    # Dec 18 22:20:17 home env[2006845]: LOCALE_ARCHIVE=/nix/store/gzali8g9fnxfzd2i15g0xmvzywx24hib-glibc-locales-2.40-36/lib/locale/locale-a>
    # Dec 18 22:20:17 home env[2006845]: TZDIR=/nix/store/dfsiy184c8z6gf5x6cqfyahxv9g16828-tzdata-2024b/share/zoneinfo
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      # User = "root";
      ExecStart = "/run/current-system/sw/bin/env";
    };
  };

  # systemd.timers = {
  #   "reboot-network-off" = {
  #     wantedBy = ["timers.target"];
  #     enable = true;
  #     timerConfig = {
  #       OnBootSec = "10m";
  #       OnUnitActiveSec = "10m";
  #       Unit = "qbittorrent-reschedule.service";
  #     };
  #   }
  # }
  #

  # systemd.timers = {
  #   # "qbittorrent-reschedule" = {
  #   #   wantedBy = ["timers.target"];
  #   #   enable = false;
  #   #   timerConfig = {
  #   #     OnBootSec = "3m";
  #   #     OnUnitActiveSec = "3m";
  #   #     Unit = "qbittorrent-reschedule.service";
  #   #   };
  #   # };
  #   # "qbittorrent-clean" = {
  #   #   wantedBy = ["timers.target"];
  #   #   enable = true;
  #   #   timerConfig = {
  #   #     OnBootSec = "3m";
  #   #     OnUnitActiveSec = "3m";
  #   #     Unit = "qbittorrent-clean.service";
  #   #   };
  #   # };
  # };

  # systemd.services."bluetooth-keyboard" = {
  #   enable = true;
  #   path = [ ];
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   environment = {
  #     WAYLAND_DISPLAY = "wayland-1";
  #     XDG_RUNTIME_DIR = "/run/user/1000";
  #   };
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "rok";
  #     Restart = "always";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/swayidle timeout 30 "" resume "/run/current-system/sw/bin/bluetoothctl connect 6C:93:08:65:FF:E4"
  #     '';
  #   };
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "virtiofs" ];

  # NOTES(24/07/07): bluetooth doesn't work, there's issue on 6.9
  # https://discourse.nixos.org/t/bluetooth-controller-issues-with-kernel-6-9/45598/3
  boot.kernelPackages = pkgs.linuxPackages_testing;
  # boot.kernelPackages = pkgs.unstable.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_latest; # use latest kernel

  boot.supportedFilesystems = [
    "nfs"
    "ntfs"
  ];
  services.rpcbind.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # virt-manager
  programs.dconf.enable = true;

  # virtualisation.qemu.guestAgent.enable = true;

  # Enable secure boot and TPM for VMs
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;

  # network
  networking.networkmanager.enable = false;
  networking.useNetworkd = false;
  networking.useDHCP = false;

  networking.enableIPv6 = true;

  systemd.network.enable = true;
  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 1;
      dhcpV6Config.RouteMetric = 1;
      # domains = ["leo-rudd.ts.net"];
    };
    "20-wireless" = {
      matchConfig.Name = "wlan0";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 2;
      dhcpV6Config.RouteMetric = 2;
      # domains = ["leo-rudd.ts.net"];
    };
  };

  # i18n.inputMethod = {
  #   type = "kime";
  #   # enable = true;
  #   # fcitx5.addons = with pkgs; [
  #   #   pkgs.fcitx5-mozc
  #   #   pkgs.fcitx5-gtk
  #   #   pkgs.fcitx5-with-addons
  #   #   pkgs.fcitx5-mozc
  #   #   # pkgs.unstable.fcitx5-qt
  #   #   # pkgs.unstable.fcitx5-chinese-addons
  #   #   pkgs.fcitx5-hangul
  #   #   # pkgs.unstable.fcitx5-lua
  #   # ];
  # };

  # services.xserver.desktopManager.runXdgAutoStartIfNone = true;

  services.upower.enable = true;
  # services.qbittorrent.enable = true;
  # services.qbittorrent.port = 4321;

  # security
  security.rtkit.enable = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rok = {
    isNormalUser = true;
    homeMode = "777";
    description = "rok";
    packages = with pkgs; [
      inputs.kata.packages.${system}.default
    ];
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

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     tailscale = pkgs.aca.tailscale;
  #   })
  # ];

  # TODO: should not use this
  # age.identityPaths = ["/home/rok/.ssh/id_ed25519"];
  # age.secrets."github.com__aca".file = ./secrets/github.com__aca.age;

  #   (
  #     let
  #       pinnedPkgs = import
  #         (pkgs.fetchFromGitHub {
  #           owner = "NixOS";
  #           repo = "nixpkgs";
  #           rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
  #           sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
  #         })
  #         { };
  #     in
  #     final: prev: {
  #       vifm = pinnedPkgs.vifm;
  #     }
  #   )
  # ];

  # nixpkgs.overlays = [
  #   # https://discourse.nixos.org/t/how-to-install-version-of-a-package-that-is-newer-then-in-nixpkgs/16450/4
  #   # NOTES:(aca) doesn't work, things that depends on go compiler breaks
  #   # (self: super: {
  #   #   go = super.go.overrideAttrs (old: {
  #   #     version = "1.21.0";
  #   #     src = pkgs.fetchurl {
  #   #       url = "https://go.dev/dl/go1.21.0.src.tar.gz";
  #   #       hash = "sha256-gY1G7ehWgt1VGtN47zek0kcAbxLsWbW3VWAdLOEUNpo=";
  #   #     };
  #   #   });
  #   # })
  #
  #   (
  #     let
  #       pinnedPkgs = import
  #         (pkgs.fetchFromGitHub {
  #           owner = "NixOS";
  #           repo = "nixpkgs";
  #           rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
  #           sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
  #         })
  #         { };
  #     in
  #     final: prev: {
  #       docker = pinnedPkgs.docker;
  #     }
  #   )
  # ];

  #   (
  #     let
  #       pinnedPkgs = import
  #         (pkgs.fetchFromGitHub {
  #           owner = "NixOS";
  #           repo = "nixpkgs";
  #           rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
  #           sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
  #         })
  #         { };
  #     in
  #     final: prev: {
  #       docker = pinnedPkgs.docker;
  #     }
  #   )
  # ];

  # (
  #   let
  #     pinnedPkgs = import
  #       (pkgs.fetchFromGitHub {
  #         owner = "NixOS";
  #         repo = "nixpkgs";
  #         rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
  #         sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
  #       })
  #       { };
  #   in
  #   final: prev: {
  #     docker = pinnedPkgs.docker;
  #   }
  # )
  # ];
  hardware.bluetooth.enable = true;

  virtualisation.docker = {
    enable = true; # replace with podman
    # package = pkgs.docker;
    daemon.settings = {
      # hosts = ["tcp://127.0.0.1:2375"];
      # hosts = ["tcp://0.0.0.0:2375"];
      # insecure-registries = import ./dev/docker.insecure-registries.nix;
    };
  };

  virtualisation.containers.registries.insecure = [
    "localhost:5000"
  ];

  # virtualisation.podman = {
  #   enable = false; # replace with podman
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  #   # package = unstable.docker;
  # };

  # nixpkgs.config.permittedInsecurePackages = [
  #   "olm-3.2.16"
  # ];

  # services.ollama.enable = true;

  # programs.firefox.nativeMessagingHosts.tridactyl = true;
  #

  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "vivaldi"
  #   ];

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  # nixpkgs.config.packageOverrides = pkgs: {
  #   # TODO: replace with AMD
  #   # vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  # };

  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     # TODO: replace with AMD
  #     # intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #     # vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #     # vaapiVdpau
  #     # libvdpau-va-gl
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  #
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      nebula
      go-audit
      openbao
      mkcert
      # neovim
      # fluffychat
      element-desktop
      ntfy-sh
      # neovide
      # pkgs.unstable.matrix-commander
      matrix-commander
      synapse-admin
      elvish
      glxinfo
      nvme-cli
      xwayland
    ]
    ++ [
      nftables
    ]
    ++ [
      # (import ./packages/sublime-merge/default.nix)
      # (import ./packages/hello/hello.nix)
      (pkgs.callPackage ./pkgs/qbt.nix { })

      # (
      #   buildGoModule rec {
      #     name = "qbt";
      #     version = "0.1";
      #     subPackages = "cmd/qbt";
      #     vendorHash = "sha256-PFI5pcwLdE/OBElwV8tm/ganH3/PI6/mCSKn6MKvIgg=";
      #     src = pkgs.fetchFromGitHub {
      #       owner = "aca";
      #       repo = "qbittorrent-cli";
      #       inherit (inputs.qbt-src) rev;
      #       hash = inputs.qbt-src.narHash;
      #     };
      #   }
      # )

      # rustdesk
    ]
    ++ [
      # cloud
      awscli2
      # pkgs.unstable.azure-cli
      # azure-storage-azcopy
      oci-cli
    ]
    ++ [
      # cloud.k8s
      kubectl
      stern
      kubectl-images
      kubectl-node-shell
      kubectl-tree
      kubectx
      kubetail

      dive

      ko
      krew
    ]
    ++ [
      # laptop
      upower
    ]
    ++ [
      # system
      glances
      htop
      iftop
      usbutils

      # pkgs.unstable.ntfy-sh
    ]
    ++ [
      # android
      # android-tools
      # android-studio
      # android-udev-rules
      # flutter
      # jdk11
      tig
      lazygit
    ]
    ++ [
      litecli
      # tools
      via
      vial

      convmv # rename filename encoding

      gimp

      # https://github.com/NixOS/nixpkgs/issues/267579
      # pkgs.unstable.virt-manager
      (virt-manager.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ wrapGAppsHook ];
        buildInputs = lib.lists.subtractLists [ wrapGAppsHook ] old.buildInputs ++ [
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
        ];
      }))
      virt-viewer
      janet
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice

      # pkgs.unstable.cockpit
    ]
    ++ [
      # browser
      # (pkgs.unstable.microsoft-edge.override {
      #   commandLineArgs = [
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9227"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #   ];
      # })
      # (pkgs.unstable.vivaldi.override {
      #   proprietaryCodecs = true;
      #   enableWidevine = false;
      # })
      # pkgs.unstable.vivaldi-ffmpeg-codecs
      # pkgs.unstable.widevine-cdm
      # (pkgs.unstable.vivaldi.override {
      #   # mesa = pkgs.mesa;
      #   commandLineArgs = [
      #     # "--ozone-platform-hint=wayland"
      #
      #     # "--ozone-platform-hint=auto"
      #     # "--enable-features=UseOzonePlatform"
      #     # "--ozone-platform-hint=''"
      #     # "--ozone-platform=''"
      #
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9223"
      #     # "--force-dark-mode"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #     # "--disable-features=UseOzonePlatform"
      #     # "--gtk-version=4" # fcitx
      #   ];
      # })
      (pkgs.chromium.override {
        commandLineArgs = [
          # "--enable-features=WebContentsForceDark"
          "--enable-quic"
          "--enable-zero-copy"
          "--remote-debugging-port=9222"
          # NOTES: ozone-platform=wayland fcitx win+space not work
        ];
      })
      (pkgs.google-chrome.override {
        commandLineArgs = [
          # "--enable-features=WebContentsForceDark"
          "--enable-quic"
          "--enable-zero-copy"
          "--remote-debugging-port=9224"
          # NOTES: ozone-platform=wayland fcitx win+space not work
        ];
      })

      # https://github.com/fcitx/fcitx5/issues/862
      # pkgs.unstable.google-chrome

      # (pkgs.unstable.google-chrome.override {
      #   commandLineArgs = [
      #     # "--ozone-platform-hint=auto"
      #     # "--enable-features=WebContentsForceDark"
      #     # "--ozone-platform-hint=wayland"
      #     # "--enable-quic"
      #     # "--enable-zero-copy"
      #     # "--enable-features=UseOzonePlatform"
      #     # "--remote-debugging-port=9222"
      #     # "--force-dark-mode"
      #     "--gtk-version=4" # fcitx
      #   ];
      # })
    ]
    ++ [
      # nodePackages_latest.fx
      # nodePackages.yaml-language-server
      # nodePackages.vscode-langservers-extracted
      # libguestfs
      # libguestfs-with-appliance # https://github.com/NixOS/nixpkgs/issues/37540
      # guestfs-tools
      exfat
      # formatter
      alejandra # nix
      gofumpt # go
      gotools # go
      gotests
      isort
      shfmt
      taplo
      vscode-fhs
      yamlfmt
      beautysh
      buf

      flatbuffers
      black
      cmake-format
    ]
    ++ [
      pup
      socat
      sops

      sqlite-interactive
      redis
      litecli
      usql
      sqls

      pciutils
      sshfs
      browsh
      # firefox-bin
      sublime-merge
      # git-cola
      sshpass
      telegram-desktop
      libnotify
      lsof
      inkscape
      pv

      # clipboard-jh
      xorg.libX11
    ]
    ++ [
      dig
      inetutils
      wget
      entr
      diskus
      pcmanfm
      zsh
      xsel
      gdb
      _9pfs
      age
      aria2
      atool
      bat
      bolt
      ov
      cron
      delta
      ipset
      dig
      hyperfine
      oauth2-proxy
      scc
      glow
      dog
      nixpkgs-fmt
      desktop-file-utils
      entr
      pandoc
      # davinci-resolve
      dura
      valgrind

      # appimage-run
      # qemu
      # act

      openai-whisper

      podman
      trash-cli
      webkitgtk
      # git-annex-utils
      gnuplot
      gron
      vbindiff
      nfs-utils
      # transmission
      # transmission-remote-gtk
      hexyl
      libisoburn
      flex
      bison
      ncurses
      jo
      asciinema
      just
      kitty
      dive
      cmatrix

      sd

      grex
      gperf
      libreoffice-qt
      lnav
      lshw
      ncdu
      # neovim
      netcat-gnu
      nginx
      nnn
      # okular

      p7zip
      unzip
      ouch

      phodav
      progress

      # (pkgs.writeScriptBin "helloworld" ''
      # #!/usr/bin/env bash
      # notify-send "qbt-torrent-add";
      # ~/bin/qbt torrent add $1;
      # ''
      # )
      #

      clickhouse

      neovim-unwrapped
      scrot
      # mitmproxy
      (luajit.withPackages (
        p: with p; [
          stdlib
        ]
      ))

      nqp
      rakudo
      pnpm_10

      wirelesstools

      tcpdump
      nmap
      openssl
      termshark
      tshark
      wireshark

      # terraform
      tig
      virtiofsd
      watchexec
      wev
      yarn
      zathura
      obsidian
      zef
      patchelf
      ttyd
      powertop
      gptfdisk
      zip

      # rav1e
      #
      xxHash
      lm_sensors
      zls

    (pulumi.withPackages (
      p: with p; [
        pulumi-go
        pulumi-nodejs
      ]
    ))

      # sway stuff
      xdragon
      alacritty # gpu accelerated terminal
      rofi-wayland
      wayland
      rustc
      cargo
      wdisplays
      xdg-utils
      waypipe
      wl-clipboard # clipboard
      xdg-utils # for opening default programs when clicking links
      dunst
      glib # gsettings
      dracula-theme # gtk theme
      # gnome3.adwaita-icon-theme # default gnome cursors
      pavucontrol
      swayidle
      pulseaudioFull
      grim # screenshot functionality
      slurp # screenshot functionality
      # bemenu # wayland clone of dmenu
      wdisplays # tool to configure displays
      kanshi

      syncthing
      mupdf
      pueue
      helix
      kakoune
      gh

      # ghostty
      gtk4
      # (pkgs.makeDesktopItem {
      #   name = "ghostty";
      #   desktopName = "ghostty";
      #   exec = "/home/rok/bin/ghostty";
      #   # mimeTypes = [];
      #   # icon = "nix-snowflake";
      # })
      #
      nushell

      rclone
      woeusb

      gcc
      wimlib
      gettext
      dnsmasq
      killall
      git
      fzf
      tmux
      fd
      ripgrep
      inetutils
      wget
      # oracle-instantclient
      coreutils-full
      findutils
      moreutils
      glibcLocales
      ghq
      stow
      buildah
      gnumake
      procps
      fluent-bit

      libpq
      postgresql

      procs
      fish
      # pkgs.unstable.vim
      # pkgs.unstable.jetbrains.idea-community
      ninja
      meson
      pkg-config
      libllvm
      # pkgs.unstable.yazi
      jetbrains.datagrip
      # neovide
      # jetbrains.clion
      x2goclient
      # emacs
      # (lowPrio uutils-coreutils-noprefix)
      freecad-wayland
      vscode.fhs
      detox
      unrar
      stylua
      # waypipe
      # wl-clipboard
      # xsel
      entr
      diskus
      kooha
      obs-studio
      zsh
      # htop
      nautilus
      cmake
      bkt

      amdgpu_top
      pwgen

      postgresql

      odin
      ols

      #   pdm
      #   (
      #     python3.withPackages (ps:
      #       with ps; [
      #         requests
      #         sqlite-utils
      #         boto3
      #         pyyaml
      #         yt-dlp
      #         pandas
      #         numpy
      #       ])
      #   )

      quartoMinimal
      # (quarto.override {
      #   python3 = pkgs.python3;
      #   extraPythonPackages =
      #     ps: with ps; [
      #       numpy
      #       jupyter
      #       pandas
      #       psycopg2
      #       plotly
      #       pyyaml
      #       jupyter
      #     ];
      # })
    ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];
  services.tailscale.extraUpFlags = [ "--accept-routes" ]; # pull whatever routes you approve
  # services.tailscale.extraDaemonFlags = [ "--tun=userspace-networking" "--socks5-server=localhost:1055" "--outbound-http-proxy-listen=localhost:1055"];

  services.spice-vdagentd.enable = true;
  # virtualisation.qemu.guestAgent.enable = true;

  # services.syncthing = {
  #   enable = true;
  #   guiAddress = "0.0.0.0:8384";
  #   user = "rok";
  #   dataDir = "/home/rok"; # Default folder for new synced folders
  #   configDir = "/home/rok/.syncthing"; # Folder for Syncthing's settings and keys
  #   settings = {
  #     devices = {
  #       # "home" = {id = "JIMRCFS-4AQYUPQ-AGCUPAT-D3GK7EN-WZAMSZM-EPSBDHE-PQFWKT5-4DWUMA3";};
  #       "root" = {
  #         id = "D5HADJL-KDECRCV-GPTJ3RE-MPXNFBH-U6KG3CA-LVSDPP2-MT72ETM-RDM77AG";
  #       };
  #       "txxx-nix" = {
  #         id = "OBPLELA-TYCW5SL-SNNFVFT-JHKT6WY-RQBDG6L-6RHVNHH-KSTKJQV-ITVQMQF";
  #       };
  #       "txxx" = {
  #         id = "BMTXVFR-DXR7XUT-TQSN65G-4SPN2SE-Z35J44T-7A4HJEE-6LRI2XT-ZHZS5QF";
  #       };
  #     };
  #   };
  # };

  services.syncthing.settings.folders = {
    "txxx" = {
      # Name of folder in Syncthing, also the folder ID
      path = "/home/rok/src/txxx"; # Which folder to add to Syncthing
      devices = [
        "txxx-nix"
        "root"
        "txxx"
      ]; # Which devices to share the folder with
    };
  };

  #  ${config.age.secrets."txxx".path}

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 4180;
        to = 4180;
      }
      {
        from = 4180;
        to = 4180;
      }
      {
        from = 2049;
        to = 2049;
      }
      {
        from = 8000;
        to = 8000;
      }
      {
        from = 8080;
        to = 8080;
      }
      {
        from = 5357;
        to = 5357;
      }
      {
        from = 80;
        to = 80;
      }
      {
        from = 443;
        to = 443;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 3702;
        to = 3702;
      } # samba
    ];
    allowPing = true;
  };

  services.samba.openFirewall = true;
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    # extraConfig = ''
    #   workgroup = WORKGROUP
    #   server string = smbnix
    #   netbios name = smbnix
    #   security = user
    #   #use sendfile = yes
    #   #max protocol = smb2
    #   # note: localhost is the ipv6 localhost ::1
    #   hosts allow = 192.168.0. 127.0.0.1 192.168.122. localhost
    #   hosts deny = 0.0.0.0/0
    #   guest account = nobody
    #   map to guest = bad user
    # '';

    # evaluation warning: The option `services.samba.shares' defined in `/nix/store/4cwn12ljgkz3dyj0d8gj7cczxmq32jzs-source/home.configuration.nix' has been renamed to `services.samba.settings'.
    # evaluation warning: The option `services.samba.securityType' defined in `/nix/store/4cwn12ljgkz3dyj0d8gj7cczxmq32jzs-source/home.configuration.nix' has been renamed to `services.samba.settings.global.security'.
    # evaluation warning: The option `hardware.opengl.extraPackages' defined in `/nix/store/4cwn12ljgkz3dyj0d8gj7cczxmq32jzs-source/home.configuration.nix' has been renamed to `hardware.graphics.extraPackages'.
    settings = {
      global = {
        security = "user";
      };
      shared = {
        path = "/home/rok/store/vm/shared";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "rok";
        "force group" = "users";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  systemd.services.failsleepexit = {
    path = [ pkgs.bash ];
    enable = true;
    serviceConfig.ExecStart = "/home/rok/src/codeberg.org/aca/nix-config/pkgs/scripts/fail.sleep.exit";
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # ubuntu_font_family
      noto-fonts
      # noto-fonts-cjk
      # comin
      noto-fonts-emoji
      iosevka
      # liberation_ttf
      # fira-code
      # fira-code-symbols
      # mplus-outline-fonts.githubRelease
      # nerdfonts
      # iosevka
      # iosevka-comfy.comfy
      # iosevka-comfy.comfy-duo
      # iosevka-comfy.comfy-fixed
      # iosevka-comfy.comfy-motion
      # dina-font
      # sarasa-gothic
      nanum
      # office-code-pro
      source-code-pro
      # (nerdfonts.override { fonts = [ "source-code-pro" ]; })
      # proggyfonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        sansSerif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        monospace = [
          "NanumGothicCoding"
          "Noto Sans Mono"
        ];
      };
    };
  };

  # services.davfs2.enable = true;

  services.nfs.server.enable = false;
  services.gvfs.enable = true;

  fileSystems."/mnt/seedbox-impx" = {
    device = "192.168.0.25:/mnt/seedbox-impx";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      # "x-systemd.requires=network-online.target"
    ];
  };

  fileSystems."/mnt/seedbox" = {
    device = "192.168.0.25:/mnt/seedbox";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      # "x-systemd.requires=network-online.target"
    ];
  };

  fileSystems."/mnt/tmp" = {
    device = "192.168.0.25:/mnt/tmp";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      # "x-systemd.requires=network-online.target"
    ];
  };

  systemd.services."shpool" = {
    description = "Shpool - Shell Session Pool";
    wantedBy = [ "default.target" ];
    requires = [ "shpool.socket" ];
    serviceConfig = {
      User = "rok";
      Type = "simple";
      ExecStart = "${pkgs.shpool}/bin/shpool daemon";
      KillMode = "mixed";
      TimeoutStopSec = "2s";
      SendSIGHUP = true;
    };
  };

  systemd.sockets."shpool" = {
    description = "Shpool Shell Session Pooler";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "%t/shpool/shpool.socket" ];
    socketConfig = {
      User = "rok";
      SocketMode = "0600";
    };
  };
}
