{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/oci-aca-001.nix
    ./pkgs/jkor-matrix.nix
    # inputs.vaultix.nixosModules.default
  ];

  # services.userborn.enable = true;

  # systemd.sysusers.enable = true;

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

  # psql -U postgres -d postgres -h 100.73.136.56 -p 5432
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "asset" ];
  #   enableTCPIP = true;
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     local all all              trust
  #     host  all all 127.0.0.1/32 trust
  #     host  all all ::1/128      trust
  #     host  all all 100.0.0.0/8 trust
  #   '';
  #   ensureUsers = [
  #     { name = "rok"; }
  #   ];
  #   settings.port = 5432;
  # };

  system.stateVersion = "24.11";
  networking.hostName = "oci-aca-001";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];
  services.tailscale.extraDaemonFlags = [ "--socks5-server=0.0.0.0:1080" ]; # blocked by firewall

  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  # age.secrets."env" = {
  #   file = ./secrets/env.oci-aca-001.age;
  #   mode = "777";
  # };
  # environment.extraInit = "source ${config.age.secrets."env".path}";

  services.openssh.enable = true;
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

  virtualisation.containers.enable = true;
  virtualisation.containers.policy = {
    default = [ { type = "insecureAcceptAnything"; } ];
    transports = {
      docker-daemon = {
        "" = [ { type = "insecureAcceptAnything"; } ];
      };
    };
  };
  virtualisation.docker = {
    enable = true; # replace with podman
    # package = pkgs.docker;
    daemon.settings = {
      # hosts = ["tcp://127.0.0.1:2375"];
      hosts = [ "tcp://0.0.0.0:2375" ];
      # insecure-registries = import ./dev/docker.insecure-registries.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    fzf
    git
    jq
    fd
    ripgrep
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
  ];
}
