{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/oci-xnzm1001-002.nix
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

  networking.hostName = "oci-xnzm1001-002";
  networking.domain = "";

  services.tailscale.enable = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@rok-txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  zramSwap.enable = true;

  # services.github-runner = {
  #   enable = true;
  #   url = ''https://github.com/investing-kr/oci-arm-host-capacity'';
  #   tokenFile = ''/root/.github'';
  #   name = ''oci-xnzm1001-002'';
  #   replace = true;
  #   extraLabels = [ "nix" ];
  #   extraPackages = with pkgs; [
  #     php82
  #     php82Packages.composer
  #   ];
  # };

  networking.firewall.enable = false;

  nixpkgs.config.permittedInsecurePackages = ["nodejs-16.20.1"];

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
    nodejs_20
    inetutils
    aria2
    elvish
    vifm
    php82
    php82Packages.composer
    wget
    coreutils-full
    microsocks
    moreutils
    glibcLocales
    ghq
    stow
    iftop
    glances
    gnumake
    entr
    procps
    vim
    zsh
    fish
    xsel
  ];
}
