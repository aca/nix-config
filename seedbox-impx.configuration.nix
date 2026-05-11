{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware/seedbox-impx.nix
    ./pkgs/scripts.nix
    ./pkgs/archive-downloads.nix
    ./pkgs/xrdp.nix
    ./pkgs/enlightment.nix
    ./pkgs/qbittorrent.nix
    ./pkgs/harmonia.nix
    # ./seedbox-impx.app.nix
  ];

  security.unprivilegedUsernsClone = true;

  system.stateVersion = "25.11";
  # boot.kernelPackages = pkgs.linuxPackages_testing;
  networking.hostName = "seedbox-impx";

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
      "qbittorrent"
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
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
    ];
  };

  services.dbus.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
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
    enabledCollectors = [ "systemd" ];
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
    ];
  };

  environment.systemPackages = with pkgs; [
    fzf
    rclone
    git
    tmux
    jq
    gcc
    go
    ripgrep
    fd
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
    ffmpeg-full
    htop
    vim
    glances
    btop
    zsh
    fish
    xsel
  ];

  # users.users.qbittorrent = {
  #   isNormalUser = true;
  #   homeMode = "777";
  #   linger = true;
  #   extraGroups = [
  #   ];
  # };
  #
  # # /run/current-system/sw/bin/curl --data "hashes=%I" "http://100.115.251.37:8080/api/v2/torrents/stop"
  #
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
}
