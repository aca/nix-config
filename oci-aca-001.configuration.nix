{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/oci-aca-001.nix
  ];

  # system.stateVersion = "23.11";
  system.stateVersion = "24.11";

  # services.ntfy-sh = {
  #   enable = true;
  #   settings = {
  #     listen-http = ":4030";
  #     base-url = "https://jkor-ntfy.duckdns.org";
  #   };
  # };

  networking.hostName = "oci-aca-001";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true"];

  age.identityPaths = ["/home/rok/.ssh/id_ed25519"];
  # age.secrets."env" = {
  #   file = ./secrets/env.oci-aca-001.age;
  #   mode = "777";
  # };
  # environment.extraInit = "source ${config.age.secrets."env".path}";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    (import ./keys.nix).rok-chatreey-t9
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
    extraGroups = ["networkmanager" "wheel" "docker" "adbusers" "libvirtd" "libvirt" "syncthing" "matrix-synapse" "cgit"];
    packages = with pkgs; [];
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

  networking.firewall.enable = false;

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
    default = [{type = "insecureAcceptAnything";}];
    transports = {
      docker-daemon = {
        "" = [{type = "insecureAcceptAnything";}];
      };
    };
  };
  virtualisation.docker = {
    enable = true; # replace with podman
    # package = pkgs.docker;
    daemon.settings = {
      # hosts = ["tcp://127.0.0.1:2375"];
      hosts = ["tcp://0.0.0.0:2375"];
      # insecure-registries = import ./dev/docker.insecure-registries.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    uv
    (
      python3.withPackages (ps:
        with ps; [
          pip
        ])
    )
    fzf
    git
    tailscale
    tmux
    ttyd
    jq
    # gcc
    # go
    fd
    github-runner
    # nodejs_20
    inetutils
    aria2
    elvish
    vifm
    php82
    php82Packages.composer
    wget
    coreutils-full
    moreutils
    glibcLocales
    # ghq
    stow
    iftop
    glances
    gnumake
    entr
    procps
    vim
    zsh
    fish
    just
    ghq
    vector
    xsel
    go
  ];
}
