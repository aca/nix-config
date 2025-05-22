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
    ./pkgs/fcitx5.nix

    ./dev/nix.nix
    ./dev/neovim_conf.nix

    # ./oci-impx-001.app.nix
  ];

  # powerManagement = {
  #   enable = true;
  #   cpufreq = {
  #     min = 100000; # Minimum 2.5 GHz
  #     max = 1400000; # Maximum 3.5 GHz
  #   };
  #   cpuFreqGovernor = "powersave";
  # };

  system.stateVersion = "25.05";
  boot.kernelPackages = pkgs.linuxPackages_testing;
  networking.hostName = "minibox";
  networking.wireless.iwd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."cryptroot".device =  "/dev/disk/by-uuid/5e4a5e6a-bea4-4330-8560-6d91e6cbdeae";

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
    gopls
    aria2
    ripgrep
    elvish
    vifm
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
    htop
    vim
    unison
    zsh
    fish
    xsel
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


    dnsmasq
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
      enp2s0.ipv4.addresses = [{
        address = "192.168.2.1";
        prefixLength = 24;
      }];
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
      # ubuntu_font_family
      noto-fonts
      # noto-fonts-cjk
      noto-fonts-emoji
      # (pkgs.nerdfonts.override { fonts = [ "IosevkaTermSlab" ]; })
      nerd-fonts.iosevka-term-slab
      # font-iosevka-term-slab-nerd-font
      # liberation_ttf
      # fira-code
      # fira-code-symbols
      # mplus-outline-fonts.githubRelease
      # nerdfonts
      iosevka
      # iosevka-comfy.comfy
      # iosevka-comfy.comfy-duo
      # iosevka-comfy.comfy-fixed
      # iosevka-comfy.comfy-motion
      # dina-font
      # sarasa-gothic
      nanum
      # office-code-pro
      source-code-pro
      # (nerdfonts.override { fonts = [ "source-code-pro" ]; })
      # proggyfonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "IBM Plex Sans KR"
          "Noto Sans Mono"
        ];
        sansSerif = [
          "IBM Plex Sans KR"
          "Noto Sans Mono"
        ];
        monospace = [ "IBM Plex Sans KR" ];
      };
    };
  };

  services.upower.enable = true;
  services.kea.dhcp4 = {
    enable = true;
    settings = {
        interfaces-config = {
          interfaces = [ "enp2s0"];
        };

    valid-lifetime = 4000;
    renew-timer =  1000;
    rebind-timer = 2000;
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp4.leases";
        };
        subnet4 = [
          {
            id = 1;
            subnet = "192.168.2.0/24";
            pools = [{ pool = "192.168.2.100 - 192.168.2.200"; }];
            # option-data = [
            #   { name = "routers"; data = "192.168.1.2"; }
            #   # { name = "domain-name-servers"; data = "8.8.8.8, 1.1.1.1"; }
            # ];
          }
        ];
        # valid-lifetime = 3600;
        loggers = [
          {
            name = "kea-dhcp4";
            output_options = [{ output = "stdout"; }];
            severity = "INFO";
          }
        ];
      };
  };
}
