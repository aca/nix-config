{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/minibox.nix
    ./dev/default.nix
    ./configuration.nix
    ./workstation.nix
    ./pkgs/sway/sway.nix


    # ./oci-impx-001.app.nix
  ];

  powerManagement = {
    enable = true;
    cpufreq = {
      min = 100000; # Minimum 2.5 GHz
      max = 1400000; # Maximum 3.5 GHz
    };
    cpuFreqGovernor = "powersave";
  };

  system.stateVersion = "25.05";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "minibox";
  networking.wireless.iwd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."cryptroot".device =  "/dev/disk/by-uuid/5e4a5e6a-bea4-4330-8560-6d91e6cbdeae";

  services.thermald.enable = false;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  # services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true" "--tun=userspace-networking" "--socks5-server=100.104.61.64:1080"];
  # services.tailscale.extraUpFlags = ["--ssh" "--advertise-exit-node=true" "--tun=userspace-networking" "--socks5-server=100.104.61.64:1080"];
  # services.tailscale.extraDaemonFlags = ["--tun=userspace-networking --socks5-server=100.104.61.64:1080"];
  services.tailscale.extraDaemonFlags = [ "--socks5-server=0.0.0.0:1080" ]; # blocked by firewall
  # services.tailscale.interfaceName = "userspace-networking";

 #  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];

  # age.secrets."env" = {
  #   file = ./secrets/env.oci-impx-001.age;
  #   mode = "777";
  # };
  # environment.extraInit = "source ${config.age.secrets."env".path}";

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
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
    ];
  };

  hardware.bluetooth.enable = true;

  services.dbus.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

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
    ripgrep
    fd
    duckdb
    sqlite-interactive
    just
    inetutils
    gopls
    aria2
    ripgrep
    elvish
    vifm
    wget
    coreutils-full
    btop
    moreutils
      dig
    glibcLocales
    ghq
    stow
    gnumake
    entr
    procps
    htop
    vim
    zsh
    fish
    xsel
    neovim-unwrapped

    (pkgs.chromium.override {
      commandLineArgs = [
        # "--enable-features=WebContentsForceDark"
        "--enable-quic"
        "--enable-zero-copy"
        "--remote-debugging-port=9222"
        # NOTES: ozone-platform=wayland fcitx win+space not work
      ];
    })


    dnsmasq
  ];

  # https://francis.begyn.be/blog/nixos-home-router
  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;
  };
# 
#   networking = {
#     useDHCP = false;
#     hostName = "router";
#     # nameserver = [ "<DNS IP>" ];
#     # Define VLANS
#     vlans = {
#       wan = {
#         id = 10;
#         interface = "enp1s0";
#       };
#       lan = {
#         id = 20;
#         interface = "enp2s0";
#       };
#       iot = {
#         id = 90;
#         interface = "enp2s0";
#       };
#     };


#   networking.nat.enable = true;
   networking.nat.internalInterfaces = [ "enp2s0" ]; # 유선인터페이스 이름에 맞게 수정

#     interfaces = {
#       # Don't request DHCP on the physical interfaces
#       enp1s0.useDHCP = false;
#       enp2s0.useDHCP = false;
#       enp3s0.useDHCP = false;
# 
#       # Handle the VLANs
#       wan.useDHCP = false;
#       lan = {
#         ipv4.addresses = [
#           {
#             address = "10.1.1.1";
#             prefixLength = 24;
#           }
#         ];
#       };
#       iot = {
#         ipv4.addresses = [
#           {
#             address = "10.1.90.1";
#             prefixLength = 24;
#           }
#         ];
#       };
#     };
#   };

  security.rtkit.enable = true;
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

  services.upower.enable = true;
}
