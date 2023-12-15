{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/oci-xnzm1001-001.nix
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

  networking.hostName = "oci-xnzm1001-001";
  networking.domain = "";

  services.tailscale.enable = true;

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@rok-toss-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  zramSwap.enable = true;

  nixpkgs.config.permittedInsecurePackages = ["nodejs-16.20.1"];

  # curl 100.79.222.108:9100/prometheus
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9100;
        listenAddress = "100.79.222.108";
      };
    };
  };

  age.identityPaths = [ "/root/.ssh/id_ed25519" ];
  age.secrets."github.com__aca".file = ./secrets/github.com__aca.age;
  services.github-runner = {
    enable = true;
    url = ''https://github.com/aca-x'';
    # tokenFile = ''/root/.github'';
    #
    tokenFile = config.age.secrets."github.com__aca".path;
    name = ''aca-x_oci-xnzm1001-001_001'';
    replace = true;
    extraLabels = [ "nix" ];
    extraPackages = with pkgs; [
      # php82
      # php82Packages.composer
    ];
  };

  networking.firewall.enable = false;
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [22 80 443];
  #   # allowedUDPPortRanges = [
  #   #   { from = 4000; to = 4007; }
  #   #   { from = 8000; to = 8010; }
  #   # ];
  # };

  environment.systemPackages = with pkgs; [
    fzf
    git
    tailscale
    tmux
    jq
    gcc
    go
    fd
    github-runner
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
}
