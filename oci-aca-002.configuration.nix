{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/oci-aca-002.nix
    ./pkgs/archive-downloads.nix
    ./pkgs/internal/ntfy.nix
  ];

  # base-url = "${config."internal.ntfy".baseUrl}";
  services.ntfy-sh.enable = true;
  services.ntfy-sh.settings = {
    behind-proxy = true;
    # allow sending notifications without authentication
    auth-default-access = "write-only";
    listen-http = "5119";
    message-delay-limit = "100d";
    cache-duration = "300h";
    cache-startup-queries = ''
      pragma journal_mode = WAL;
      pragma synchronous = normal;
      pragma temp_store = memory;
      pragma busy_timeout = 15000;
      vacuum;
    '';
  };

  nix.settings = {
    max-jobs = 1;
    cores = 1;
  };

  # 1c/1g 서버 성능 최적화
  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
  services.udisks2.enable = false;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };

  services.victorialogs.enable = true;
  # curl -N http://oci-aca-001:9428/select/logsql/tail -d 'query=*'
  # curl 'http://oci-aca-001:9428/internal/force_flush'
  services.victorialogs.extraOptions = [
    # "-retention.maxDiskUsagePercent=50"
    "-retentionPeriod=30d"
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
  '';

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
  };

  services.victoriametrics.enable = true;
  services.victoriametrics.extraOptions = [
    "-search.latencyOffset=0s"
    "-retentionPeriod=100y"
  ];

  systemd.services."xpra-chromium" = {
    enable = true;
    serviceConfig = {
      User = "rok";
      MemoryHigh = "500M";
      MemoryMax = "700M";
      CPUWeight = 50;
    };
    script = "${pkgs.xpra}/bin/xpra start :100 --start=${pkgs.chromium}/bin/chromium --daemon=no";
    wantedBy = [ "network-online.target" ];
  };

  system.stateVersion = "25.11";
  networking.hostName = "oci-aca-002";

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

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];

  services.tailscale.extraDaemonFlags = [
    # "--ssh"
    "--socks5-server=0.0.0.0:1080"
  ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    (import ./keys.nix).seedbox
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];

  zramSwap.enable = true;

  # services.github-runner = {
  #   enable = true;
  #   url = ''https://github.com/investing-kr/oci-arm-host-capacity'';
  #   tokenFile = ''/root/.github'';
  #   name = ''oci-aca-002'';
  #   replace = true;
  #   extraLabels = [ "nix" ];
  #   extraPackages = with pkgs; [
  #     php82
  #     php82Packages.composer
  #   ];
  # };

  networking.firewall = {
    enable = true;
    logRefusedConnections = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
    allowedUDPPorts = [
      22
      80
      443
    ];
  };

  # nixpkgs.config.permittedInsecurePackages = ["nodejs-16.20.1"];
  # age.identityPaths = ["/root/.ssh/id_ed25519"];
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
    fzf
    git
    fish
    elvish
    python3
    vim
    tmux
    xpra
    (pkgs.chromium.override {
      commandLineArgs = [
        # "--enable-features=WebContentsForceDark"
        "--enable-quic"
        "--disable-gpu"
        "--enable-zero-copy"
        "--disable-features=DarkMode"
        # "--ozone-platform=x11"
        "--remote-debugging-port=9222"
        "--user-data-dir=/home/rok/store/chromium.oci-aca-002"
        # NOTES: ozone-platform=wayland fcitx win+space not work
      ];
    })
    jq
    go
    entr
    aria2
    ghq
  ];
}
