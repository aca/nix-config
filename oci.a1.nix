{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
let
in
rec {
  imports = [
    ./pkgs/archive-downloads.nix
    ./pkgs/scripts.nix
    ./linux.configuration.nix
    ./pkgs/xpra-chromium.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;


  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraDaemonFlags = [
    "--socks5-server=0.0.0.0:1080"
    "-verbose=9"
  ];

  services.vnstat.enable = true;

  environment.systemPackages = with pkgs; [
    fzf
    xpra
    rclone
    git
    ffmpeg-bin
    tmux
    qbittorrent-enhanced-nox
    jq
    gcc
    go-nightly
    ripgrep
    fd
    inetutils
    aria2
    ripgrep
    elvish
    vifm
    wget
    coreutils-full
    chromium
    moreutils
    ghq
    stow
    gnumake
    entr
    procps
    htop
    neovim
    btop
    zsh
    fish
    xsel
  ];


  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

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
    openssh.authorizedKeys.keys = [
      (import ./keys.nix).root
      (import ./keys.nix).home
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    ];
  };

  services.tailscale.permitCertUid = "caddy";
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

  services.dbus.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];

  zramSwap.enable = true;
}
