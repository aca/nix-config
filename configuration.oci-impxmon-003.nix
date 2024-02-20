{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/oci-impxmon-003.nix
  ];

  system.stateVersion = "23.11";

  networking.hostName = "oci-impxmon-003";
  networking.domain = "";

  services.tailscale.enable = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@rok-toss-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  zramSwap.enable = true;

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
    wget
    coreutils-full
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
