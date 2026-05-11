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

  secrets = builtins.exec [
    "bash"
    "-c"
    "age --decrypt -i /root/.ssh/id_ed25519 ./secrets/archive-0.nix.age"
  ];
in
{
  imports = [
    ./hardware/archive-0.nix
    ./dev/python.nix
    ./archive-0.monitoring.nix
    ./archive-0.storage.nix
    ./archive-0.samba.nix
    ./archive-0.nfs.nix
    # ./tor.nix
    ./pkgs/scripts.nix

    ./ntfy.nix

    # ./pkgs/jkor-matrix.nix
    ./networking.nix
  ];

  programs.nix-ld.enable = true;

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  # disable intel CPU mitigations for performance
  # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
  boot.kernelParams = [
    "mitigations=off"
  ];

  # NFS permission
  environment.extraInit = "umask 0000";

  # https://github.com/nix-community/srvos/blob/main/nixos/server/default.nix#L75
  #
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

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    settings.Manager = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 7.5s.
      # If the hardware watchdog does not get a signal for 15s,
      # it will forcefully reboot the system.
      RuntimeWatchdogSec = lib.mkDefault "30s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      RebootWatchdogSec = lib.mkDefault "60s";
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      KExecWatchdogSec = lib.mkDefault "2m";
    };
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
  # services.scrutiny.enable = true;
  # services.scrutiny.collector.enable = true;
  # services.scrutiny.settings.web.influxdb.tls.insecure_skip_verify = true;
  # services.scrutiny.collector.schedule = "*-*-* 05:00:00";
  # services.scrutiny.collector.settings.log.level = "DEBUG";

  boot.loader.systemd-boot.enable = true; # use systemd-boot instead of grub
  boot.loader.efi.canTouchEfiVariables = true;

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
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
      catfs
      gptfdisk
      dmidecode
      mergerfs
      elvish
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
      stash
      bat
      iftop
      btop
      ghq
      go
      ethtool
      mpv
      pciutils
      ffmpeg-full
      curl
      htop
      glibcLocales
      tmux
      hddtemp
      git
      aria2
      hdparm
      bun
      fzf
      neovim
      progress
    ];

  # Nix
  system.stateVersion = "25.11";

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

  # Rclone WebDAV 서버
  # systemd.services.webdav-tmp = {
  #   description = "Rclone WebDAV server";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = ''
  #       ${pkgs.rclone}/bin/rclone serve webdav /mnt/tmp --addr :5005 --vfs-cache-mode off
  #     '';
  #     Restart = "always";
  #   };
  # };

  # services.vector.journaldAccess = true;
  # services.vector.enable = true;
  # services.vector.settings = builtins.fromTOML (builtins.readFile ./vector.systemd.toml);
  # serviceConfig = {
  #   Type = "simple";
  #   ExecStart = ''
  #     ${pkgs.rclone}/bin/rclone serve webdav /mnt/tmp --addr :5005 --vfs-cache-mode off
  #   '';
  #   Restart = "always";
  # };
  # services.vector.journaldAccess = true;
  # services.vector.enable = true;
  # services.vector.settings = builtins.fromTOML (builtins.readFile ./vector.systemd.toml);

  services.rsyncd.enable = true;
  services.rsyncd.settings = {
    sections = {
      tmp = {
        comment = "tmp";

        "read only" = "false";
        path = "/mnt/tmp";
      };
    };
  };
}
