{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/oci-aca-003.nix
  ];

  virtualisation.podman = {
     enable = true;
     dockerCompat = true;
     # defaultNetwork.settings.dns_enabled = true;
  };


  nix.settings = {
    max-jobs = 1;
    cores = 1;
  };

  # system.stateVersion = "25.05";
  system.stateVersion = "25.05";

  networking.hostName = "oci-aca-003";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    (import ./keys.nix).seedbox
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  zramSwap.enable = true;

  # services.github-runner = {
  #   enable = true;
  #   url = ''https://github.com/investing-kr/oci-arm-host-capacity'';
  #   tokenFile = ''/root/.github'';
  #   name = ''oci-aca-003'';
  #   replace = true;
  #   extraLabels = [ "nix" ];
  #   extraPackages = with pkgs; [
  #     php82
  #     php82Packages.composer
  #   ];
  # };

  networking.firewall.enable = false;

  # nixpkgs.config.permittedInsecurePackages = ["nodejs-16.20.1"];
  # age.identityPaths = ["/root/.ssh/id_ed25519"];
  # age.secrets."github.com__aca__oci-aca-003.age".file = ./secrets/github.com__aca__oci-aca-003.age;
  # services.github-runners.aca__oci-arm-host-capacity__oci-aca-003_001 = {
  #   enable = true;
  #   url = ''https://github.com/aca/oci-arm-host-capacity'';
  #   tokenFile = config.age.secrets."github.com__aca__oci-aca-003.age".path;
  #   replace = true;
  #   extraLabels = ["nix"];
  #   extraPackages = with pkgs; [
  #     php82
  #     php82Packages.composer
  #   ];
  # };

  environment.systemPackages = with pkgs; [
    # fzf
    git
    # tailscale
    # tmux
    # ttyd
    # jq
    # # gcc
    # # go
    # fd
    # github-runner
    # # nodejs_20
    # inetutils
    # aria2
    # elvish
    # vifm
    # php82
    # php82Packages.composer
    # wget
    # coreutils-full
    # moreutils
    # glibcLocales
    # # ghq
    # stow
    # iftop
    # glances
    # gnumake
    # entr
    # procps
    # vim
    # zsh
    # fish
    # xsel
  ];
}
