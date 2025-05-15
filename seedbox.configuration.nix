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
    nfs-utils
    fd
    just
    inetutils
    aria2
    elvish
    vifm
    wget
    coreutils-full
    bun
    gopls
    moreutils
    glibcLocales
    ghq
    stow
    gnumake
    entr
    procps
    vim
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
    /Downloads     100.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
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
}
