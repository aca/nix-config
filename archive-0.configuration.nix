# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  hostname = "archive-0";
in
{
  imports = [
    ./hardware/archive-0.nix
    ./archive-0.monitoring.nix
    ./archive-0.storage.nix
    ./archive-0.samba.nix
    ./archive-0.nfs.nix

    # ./pkgs/jkor-matrix.nix
    ./networking.nix
  ];

  services.nebula.networks.nas = {
    enable = true;
    isLighthouse = true;
    # staticHostMap = {
    #     "192.168.100.1" = [ ];
    # };
    # cert = "/etc/nebula/archive-0.crt";
    # key = "/etc/nebula/archive-0.key";
    # ca = "/etc/nebula/ca.crt";
  };

  # NFS permission
  environment.extraInit = "umask 0000";


  # Given that our systems are headless, emergency mode is useless.
  # We prefer the system to attempt to continue booting so
  # that we can hopefully still access it remotely.
  boot.initrd.systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
    "emergency.service"
    "emergency.target"
  ];

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 7.5s.
      # If the hardware watchdog does not get a signal for 15s,
      # it will forcefully reboot the system.
      runtimeTime = lib.mkDefault "15s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = lib.mkDefault "30s";
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      kexecTime = lib.mkDefault "1m";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  # programs.direnv = {
  #   enable = lib.mkForce false;
  #   nix-direnv.enable = lib.mkForce false;
  # };

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
    ];
    packages = with pkgs; [ ];
  };

  # Hostname
  networking.hostName = "archive-0";

  age.identityPaths = [ "/root/.ssh/id_ed25519" ];
  # age.secrets."home.services.matrix-sliding-sync.environmentFile".file = ./secrets/home.services.matrix-sliding-sync.environmentFile.age;
  # age.secrets."x".file = ./secrets/xxxxx.age;
  # config.eistration_shared_secret = builtins.readFile config.age.secrets.eistration_shared_secret.path;
  #
  # age.secrets.xxx.file = ./secrets/agenixtest.age;
  # age.secrets.xxx.file = ./secrets/home.services.matrix-synapse.extraConfigFiles.age;

  # SSH keys
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];
  services.openssh.enable = true; # Enable the OpenSSH daemon.

  # Firewall https://nixos.wiki/wiki/Firewall
  networking.firewall.enable = false;

  # Use systemd-networkd instead of networkd, remove all to just use networkd.
  networking.useNetworkd = false;
  networking.useDHCP = false;
  networking.networkmanager.enable = false;
  systemd.network.enable = true;
  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 1;
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  # systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  services.tailscale.enable = true; # enable tailscale
  services.tailscale.permitCertUid = "caddy";

  services.fwupd.enable = true; # Hardware update with fwupd

  # scrutiny
  # services.smartd.enable = false;
  services.scrutiny.enable = false;
  services.scrutiny.collector.enable = false;
  services.scrutiny.settings.web.influxdb.tls.insecure_skip_verify = true;
  services.scrutiny.collector.schedule = "*-*-* 05:00:00";
  services.scrutiny.collector.settings.log.level = "DEBUG";

  boot.kernelPackages = pkgs.linuxPackages_latest; # use latest kernel
  boot.loader.systemd-boot.enable = true; # use systemd-boot instead of grub
  boot.loader.efi.canTouchEfiVariables = true;

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "en_US.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "en_US.UTF-8";
  #   LC_TIME = "en_US.UTF-8";
  # };
  time.timeZone = "Asia/Seoul";

  # https://wiki.nixos.org/wiki/Power_Management#Hard_drives
  services.udev.extraRules =
    let
      mkRule = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in
    mkRules [
      (mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{queue/rotational}=="1"''
        ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 240 /dev/%k"''
      ])
    ];

  # Packages installed in system profile.
  environment.systemPackages =
    with pkgs;
    [
      gptfdisk
      mergerfs
      smartmontools
      nfs-utils
      lsof
    ]
    ++ [
      vim
      vifm
      shpool
      sqlite-interactive
      glances
      duckdb
      fd
      bat
      iftop
      btop
      nethogs
      ghq
      go
      ethtool
      mpv
      pciutils
      curl
      fish
      htop
      glibcLocales
      tmux
      hddtemp
      git
      aria2
      python3
      hdparm
      bun
      fzf
      neovim
      progress
    ];

  # Prevent hang
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=240s
  '';

  # Nix
  system.stateVersion = "25.05";

  # ntfy user add --role=admin root
  # services.ntfy-sh = {
  #   enable = true;
  #   settings = {
  #     base-url = "https://jkor-ntfy.duckdns.org";
  #     listen-http = ":2556";
  #     behind-proxy = true;
  #     # allow sending notifications without authentication
  #     auth-default-access = "write-only";
  #     message-delay-limit = "100d";
  #     cache-duration = "144h";
  #     cache-startup-queries = ''
  #       pragma journal_mode = WAL;
  #       pragma synchronous = normal;
  #       pragma temp_store = memory;
  #       pragma busy_timeout = 15000;
  #       vacuum;
  #     '';
  #   };
  # };

  # systemd.services.caddy.serviceConfig.StandardOutput = "/root/caddy.stdout.log";
  # systemd.services.caddy.serviceConfig.StandardError = "/root/caddy.stderr.log";
  # systemd.services.caddy.serviceConfig.ProtectHome =  lib.mkForce "false";

  services.caddy.enable = true;
  services.caddy.logFormat = ''
    output stdout
    level DEBUG
  '';
  services.caddy.virtualHosts."http://archive-0".extraConfig = ''
    handle_path /scrutiny {
      reverse_proxy http://localhost:8080
    }
  '';

  fonts.fontconfig.enable = lib.mkDefault false;
}
