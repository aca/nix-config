{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/oci-xnzm-001.nix
  ];

  system.stateVersion = "24.05";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "oci-xnzm-001";

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true"];

  services.openssh.enable = true;
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
    enabledCollectors = ["systemd"];
    extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat"];
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
    git
    tmux
    jq
    gcc
    go
    fd
    just
    inetutils
    aria2
    elvish
    vifm
    wget
    coreutils-full
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
