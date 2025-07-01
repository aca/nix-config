# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#
{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  hostName = "workbox";
in
{
  imports = [
    ./hardware/workbox.nix
    ./pkgs/sway/sway.nix
    ./pkgs/fcitx5.nix
    ./pkgs/zapret.nix
    ./dev/data.nix
    ./dev/java.nix
    ./dev/default.nix
    ./dev/go.nix
    ./dev/container.nix
    # ./dev/zig.nix
    ./dev/rust.nix
    ./dev/lua.nix
    ./dev/js.nix
    ./dev/python.nix
    ./dev/nix.nix
  ];

  # boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.kernelModules = [ "8821ce" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
      rtl8821ce
  ];
  boot.blacklistedKernelModules = [ "rtw88_8821ce" ]; 


  boot.extraModprobeConfig = ''
    options rtw88 lps_deep_mode=0
  '';


  systemd.tmpfiles.rules = [
    # 형식: "d <path> <mode> <uid> <gid> <age>"
    # %u → 실제 사용자 이름, %h → 사용자 홈 디렉토리
    "d /home/%u/src 0755 - - -"
    "d /home/%u/.local/share/nvim/ 0755 - - -"
  ];

  services.udev.packages = with pkgs; [
    via
    vial
  ];

  # services.caddy.enable = true;
  # services.caddy.virtualHosts."http://torrent.workbox".extraConfig = ''
  #   reverse_proxy http://localhost:4321
  # '';

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      # TODO: replace with AMD
      # intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      # vaapiVdpau
      # libvdpau-va-gl
    ];
  };

  # networking.wireless.iwd.enable = true;

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  #   git
  #
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = true;

  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/ae008286-6f50-451f-b9fd-bcce78770f49";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # services.prometheus.enable = true;
  # services.prometheus.globalConfig.scrape_interval = "15s"; # "1m"
  # services.prometheus.extraFlags = ["--log.level=debug"];
  # services.prometheus.scrapeConfigs = [
  #   {
  #     job_name = "node";
  #     static_configs = [
  #       {targets = ["100.101.62.82:9000"];}
  #     ];
  #   }
  # ];
  # services.prometheus.alertmanagers = [
  #   {
  #     scheme = "http";
  #     static_configs = [
  #       {targets = ["localhost:${toString config.services.prometheus.alertmanager.port}"];}
  #     ];
  #   }
  # ];

  hardware.bluetooth.enable = true;
  #
  # services.prometheus.ruleFiles = [
  #   ./node-exporter.yml
  # ];

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

  # services.prometheus.alertmanager = {
  #   enable = true;
  #   configuration = {
  #     route = {
  #       receiver = "ntfy";
  #       group_wait = "30s";
  #       group_interval = "5m";
  #       repeat_interval = "4h";
  #       group_by = ["alertname" "job"];
  #       routes = [];
  #     };
  #     receivers = [
  #       {
  #         name = "ntfy";
  #         webhook_configs = [
  #           {
  #             url = "https://ntfy.sh/qQe2btaC6w8Qho7k";
  #           }
  #         ];
  #       }
  #     ];
  #   };
  # };

  # services.grafana.provision.datasources.settings = {
  #   apiVersion = 1;
  #   datasources = [
  #     {
  #       name = "Prometheus";
  #       type = "prometheus";
  #       url = "http://0.0.0.0:9090";
  #       orgId = 1;
  #     }
  #   ];
  # };

  # services.grafana.provision.dashboards.settings.providers = [
  #   {
  #     name = "node";
  #     options.path = ./grafana/dashboards/1860_rev37.json;
  #   }
  # ];
  #
  # services.prometheus.exporters.node = {
  #   enable = true;
  #   port = 9000;
  #   # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
  #   enabledCollectors = ["systemd"];
  #   extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat"];
  # };

  # services.loki.enable = true;

  # # socks5 proxy
  # # sh -c 'https_proxy="socks5://localhost:1337" http_proxy="socks5://localhost:1337" curl -vv https://ifconfig.me'
  # systemd.user.services."proxy-socks5" = {
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/ssh -v -D 1337 -q -C root@oci-xnzm-002 "sh -c 'while :; do echo 1; sleep 2073600; done'"
  #       sleep 10
  #     '';
  #   };
  # };

  # sh -c 'https_proxy="socks5://localhost:1337" http_proxy="socks5://localhost:1337" curl -vv https://ifconfig.me'
  # systemd.services."proxy-socks5" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     User = "rok";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/ssh -v -D 1337 -q -C root@oci-xnzm-002 "sh -c 'while :; do date; sleep 2073600; done'"
  #     '';
  #   };
  # };

  # services.tailscale.enable = true;

  # fileSystems."/mnt/archive-0" = {
  #   device = "192.168.0.25:/mnt/archive-0";
  #   fsType = "nfs";
  #   options = ["noatime"];
  # };

  # fileSystems."/mnt/rok-chatreey-t9/cache".device = "/dev/disk/by-uuid/c9c56be8-254e-4a7f-8134-83a6dfade66c";
  # fileSystems."/mnt/rok-chatreey-t9/cache".fsType = "ext4";
  # fileSystems."/mnt/rok-chatreey-t9/cache".options = ["defaults" "nofail" "users"];

  # system.activationScripts.fix-perm.text = "chmod 777 /mnt/rok-chatreey-t9/cache";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  services.fwupd.enable = true;
  networking.hostName = "workbox"; # Define your hostname.
  #  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = false;
  networking.useNetworkd = false;
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks = {
    "20-wireless" = {
      matchConfig.Name = "wlan0";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 2;
    };
    "10-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 1;
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";


  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "ko_KR.UTF-8";
  #   LC_IDENTIFICATION = "ko_KR.UTF-8";
  #   LC_MEASUREMENT = "ko_KR.UTF-8";
  #   LC_MONETARY = "ko_KR.UTF-8";
  #   LC_NAME = "ko_KR.UTF-8";
  #   LC_NUMERIC = "ko_KR.UTF-8";
  #   LC_PAPER = "ko_KR.UTF-8";
  #   LC_TELEPHONE = "ko_KR.UTF-8";
  #   LC_TIME = "ko_KR.UTF-8";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver = {
  #   layout = "us";
  #   xkbVariant = "";
  # };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rok = {
    isNormalUser = true;
    description = "rok";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    linger = true;
    packages = with pkgs; [ ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  # Allow unfree packages

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    pueue
    htop
    # gptfdisk

    # (pkgs.callPackage ./pkgs/qbt.nix {})
    tmux
    git
    ripgrep
    aria2
    # qbittorrent-nox
    fish
    btop
    htop
    ncdu
    glances
    lsof
    psmisc
    elvish

    dconf # https://github.com/nix-community/home-manager/issues/3113
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.openssh.settings.PermitRootLogin = "yes";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # services.nfs.server.enable = true;
  # services.nfs.server.exports = ''
  #   /mnt/rok-chatreey-t9/cache 192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0,fsid=9eebb861-b9b3-415d-a2ff-bd0ab28ff29a) 100.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0,fsid=9eebb861-b9b3-415d-a2ff-bd0ab28ff29a)
  # '';
  #
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];
}
