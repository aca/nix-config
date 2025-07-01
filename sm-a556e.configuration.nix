{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/sm-a556e.nix
    ./dev/default.nix
    ./desktop.linux.nix
    ./configuration.nix
    ./workstation.nix
    ./dev/lua.nix
    ./dev/python.nix
    ./pkgs/sway/sway.nix
    # ./pkgs/fcitx5.nix

    ./dev/nix.nix
    ./dev/neovim_conf.nix

    # ./oci-impx-001.app.nix
  ];

  programs.mosh.enable = true;

  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  age.secrets."env" = {
    file = ./secrets/env.sm-a556e.age;
    mode = "777";
  };
  environment.extraInit = "source ${config.age.secrets."env".path}";

  # powerManagement = {
  #   enable = true;
  #   cpufreq = {
  #     min = 100000; # Minimum 2.5 GHz
  #     max = 1400000; # Maximum 3.5 GHz
  #   };
  #   cpuFreqGovernor = "powersave";
  # };

  system.stateVersion = "25.05";
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "sm-a556e";
  networking.wireless.iwd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."cryptroot".device =
    "/dev/disk/by-uuid/5e4a5e6a-bea4-4330-8560-6d91e6cbdeae";

  services.thermald.enable = true;

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
      (import ./keys.nix).txxx-nix
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
    enable = false;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  environment.systemPackages = with pkgs; [
    zoom-us

    windsurf
    fzf
    git
    tmux
    jq
    gcc
    ethtool
    go
    ripgrep
    fd
    duckdb
    sqlite-interactive
    just
    inetutils
    vtsls

    (pulumi.withPackages (
      p: with p; [
        pulumi-go
        pulumi-nodejs
      ]
    ))
    gopls
    aria2
    tmux-xpanes
    jetbrains.datagrip
    ripgrep
    elvish
    nodejs
    vifm
    perses
    tyson
    aeron
    wget
    coreutils-full
    btop
    pciutils
    moreutils
    dig
    glibcLocales
    ghq
    stow
    gnumake
    entr
    procps
    libreoffice
    beekeeper-studio
    htop
    neomutt
    vim
    unison
    zsh
    sublime-merge
    pnpm
    fish
    xsel
    watchexec
    neovim-unwrapped

    (pkgs.chromium.override {
      commandLineArgs = [
        "--enable-features=WebContentsForceDark"
        "--enable-quic"
        "--enable-zero-copy"
        "--remote-debugging-port=9222"
        "--user-agent='Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36'"
        # NOTES: ozone-platform=wayland fcitx win+space not work
      ];
    })

    # dnsmasq
  ];

  # https://francis.begyn.be/blog/nixos-home-router
  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;
  };

  # networking.nameservers = ["8.8.8.8"];

  # # 네트워크 설정
  networking = {
    useDHCP = true;
    interfaces = {
      wlan0 = {
        useDHCP = true;
      };
      enp2s0.ipv4.addresses = [
        {
          address = "192.168.2.1";
          prefixLength = 24;
        }
      ];
    };

    # NAT 설정: wlan0을 통해 나가는 트래픽 masquerade
    nat = {
      enable = true;
      externalInterface = "wlan0";
      internalInterfaces = [ "enp2s0" ];
    };

    # DHCP 서버 활성화 (내부망)
    # dhcpcd = {
    #   enable = true;
    #   allowInterfaces = [ "enp2s0" ];
    #   extraConfig = ''
    #     subnet 192.168.2.0 netmask 255.255.255.0 {
    #       range 192.168.2.100 192.168.2.200;
    #       option routers 192.168.2.1;
    #     }
    #   '';
    # };
  };

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

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      ibm-plex
      nerd-fonts.iosevka-term-slab
      nerd-fonts.sauce-code-pro
      nerd-fonts.blex-mono
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          # "IBM Plex Sans KR"
          "Noto Sans Mono"
        ];
        sansSerif = [
          # "IBM Plex Sans KR"
          "Noto Sans Mono"
        ];
        monospace = [
          "Noto Sans Mono"
          # "IBM Plex Sans KR"
        ];
      };
    };
  };

  services.upower.enable = true;
  # services.kea.dhcp4 = {
  #   enable = true;
  #   settings = {
  #     interfaces-config = {
  #       interfaces = [ "enp2s0" ];
  #       service-sockets-max-retries = 5;
  #       service-sockets-retry-wait-time = 5000;
  #     };
  #
  #     valid-lifetime = 10000;
  #     renew-timer = 5000;
  #     rebind-timer = 5000;
  #     lease-database = {
  #       type = "memfile";
  #       persist = true;
  #       name = "/var/lib/kea/dhcp4.leases";
  #     };
  #     subnet4 = [
  #       {
  #         id = 1;
  #         subnet = "192.168.2.0/24";
  #         pools = [ { pool = "192.168.2.100 - 192.168.2.200"; } ];
  #         # option-data = [
  #         #   { name = "routers"; data = "192.168.1.2"; }
  #         #   # { name = "domain-name-servers"; data = "8.8.8.8, 1.1.1.1"; }
  #         # ];
  #       }
  #     ];
  #     # valid-lifetime = 3600;
  #     loggers = [
  #       {
  #         name = "kea-dhcp4";
  #         output_options = [ { output = "stdout"; } ];
  #         severity = "DEBUG";
  #       }
  #     ];
  #   };
  # };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # virtualisation.docker = {
  #   enable = true; # replace with podman
  #   # package = pkgs.docker;
  #   daemon.settings = {
  #     # hosts = ["tcp://127.0.0.1:2375"];
  #     # hosts = ["tcp://0.0.0.0:2375"];
  #     # insecure-registries = import ./dev/docker.insecure-registries.nix;
  #   };
  # };

  services.udev.packages = with pkgs; [
    via
    vial
  ];

  # https://discourse.nixos.org/t/removing-persistent-boot-messages-for-a-silent-boot/14835/10
  # Boot
  boot = {
    # Plymouth
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
  };

  systemd.services."xxx" = {
    serviceConfig.User = "rok";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "5s";
    # serviceConfig.WorkingDirectory = "/home/rok/src/github.com/investing-kr/bot/cmd/trader-buy-cancel";
    wantedBy = [ "network.target" ];
    path = [ "/run/current-system/sw" ];
    script = "sleep 1000";
  };
}
