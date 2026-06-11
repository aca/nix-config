{
  config,
  pkgs,
  lib,
  ...
}:
{
  # https://sidhion.com/blog/nixos_server_issues

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vpl-gpu-rt
  ];

  services.udisks2.enable = false; # 자동 마운트 필요없으면
  services.avahi.enable = false; # mDNS 안 쓰면
  services.printing.enable = false; # 프린터 안 쓰면
  documentation.nixos.enable = false;

  imports = [
    ./hardware/sm-a556e.nix
    ./dev/default.nix
    ./dev/git.nix
    ./linux.desktop.nix
    ./linux.configuration.nix
    ./configuration.nix
    ./workstation.nix
    ./pkgs/fcitx5.nix
    ./pkgs/zt-txxx.nix
    # ./pkgs/i3.nix
    # # ./dev/lua.nix
    # # ./dev/python.nix
    # # ./dev/java.nix
    ./pkgs/sway/sway.nix
    ./pkgs/scripts.nix
    # # ./pkgs/fcitx5.nix
    #
    ./dev/nix.nix
    ./dev/neovim_conf.nix
  ];

  services.openssh.enable = lib.mkForce true;

  # disable message
  # boot.kernel.sysctl."kernel.printk" = "0 4 1 7";

  environment.sessionVariables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.oracle-instantclient ];
    GOPRIVATE = "github.com/investing-kr,github.com/aca,git.internal";
    GONOSUMDB = "github.com/investing-kr,github.com/aca,git.internal";
    LIBVA_DRIVER_NAME = "iHD"; # Intel hardware video decode
  };

  programs.kdeconnect.enable = true;
  programs.mosh.enable = true;

  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  age.secrets."env" = {
    file = ./secrets/env.sm-a556e.age;
    mode = "777";
  };
  environment.extraInit = "source ${config.age.secrets."env".path}";

  # powerManagement.cpuFreqGovernor = "performance";
  # powerManagement.enable = false;
  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "25.11";
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  networking.hostName = "sm-a556e";
  networking.wireless.iwd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-label/cryptroot";
  boot.initrd.luks.devices."cryptroot".preOpenCommands = "";

  # aes_generic is built-in (=y) in cachyos-lto kernel, not a loadable module
  boot.initrd.luks.cryptoModules = [
    "aes"
    "blowfish"
    "twofish"
    "serpent"
    "cbc"
    "xts"
    "lrw"
    "sha1"
    "sha256"
    "sha512"
    "af_alg"
    "algif_skcipher"
    "cryptd"
    "input_leds"
  ];

  networking.hosts = {
    "100.127.31.30" = [ "git.internal" ];
  };

  boot.kernelModules = [ "tcp_bbr" ];
  services.fstrim.enable = true;
  services.irqbalance.enable = true;
  boot.tmp.useTmpfs = true;

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    ];
  };

  hardware.bluetooth.enable = true;

  services.dbus.enable = true;

  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  # services.smartdns.enable = true;

  # networking.nameservers = [ "127.0.0.1" ];
  # services.adguardhome = {
  #   enable = true;
  #   port = 4500;
  #   host = "127.0.0.1";
  #   settings = {
  #     dns = {
  #       bind_hosts = [
  #         "127.0.0.1"
  #       ];
  #     };
  #     # filtering = {
  #     #   rewrites = [
  #     #     {
  #     #       domain = "xxxxxxxxxxxxxxtest.com";
  #     #       answer = "192.168.50.20";
  #     #     }
  #     #   ];
  #     # };
  #   };
  # };

  environment.systemPackages = with pkgs; [
    omnissa-horizon-client
    nftables
    kanata
    tcpdump

    iptables
    go-nightly
    # zoom-us

    fzf
    git
    tmux
    jq
    gcc
    ethtool

    iptables
    go
    ripgrep
    fd
    duckdb
    quarto
    remmina
    sqlite-interactive
    just
    inetutils
    vtsls
    xpra
    typst
    sqlc
    wireguard-tools

    (pulumi.withPackages (
      p: with p; [
        pulumi-go
        pulumi-nodejs
      ]
    ))
    alacritty
    gopls
    aria2
    awscli2
    tmux-xpanes
    mpv
    jetbrains.datagrip
    jujutsu
    ripgrep
    pandoc
    elvish
    nodejs
    vifm
    # perses
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
    htop
    neomutt
    vim
    unison
    zsh
    # vmware-horizon-client
    sublime-merge
    pnpm
    sshuttle
    python3
    fish
    xsel
    killall
    psmisc
    watchexec
    neovim-unwrapped

    # "--enable-features=WebContentsForceDark"
    (pkgs.google-chrome.override {
      commandLineArgs = [
        "--remote-debugging-port=9222"
        # "--user-agent='Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36'"
        # NOTES: ozone-platform=wayland fcitx win+space not work
      ];
    })

    (pkgs.chromium.override {
      commandLineArgs = [
        # "--enable-quic"
        # "--enable-zero-copy"
        "--remote-debugging-port=9223"
        # "--user-agent='Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36'"
        # NOTES: ozone-platform=wayland fcitx win+space not work
      ];
    })

    # dnsmasq
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 75;
  };

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.page-cluster" = 0; # single page readahead for zram (sequential readahead wasteful for compressed swap)
    "vm.compaction_proactiveness" = 0; # reduce background CPU compaction work

    "kernel.split_lock_mitigate" = 0; # avoid split-lock detection penalty
    "kernel.nmi_watchdog" = 0; # disable NMI watchdog

    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # networking.nameservers = ["8.8.8.8"];

  # # 네트워크 설정
  # networking = {
  #   useDHCP = true;
  #   interfaces = {
  #     wlan0 = {
  #       useDHCP = true;
  #     };
  #     enp2s0.ipv4.addresses = [
  #       {
  #         address = "192.168.2.1";
  #         prefixLength = 24;
  #       }
  #     ];
  #   };
  #
  #   # NAT 설정: wlan0을 통해 나가는 트래픽 masquerade
  #   nat = {
  #     enable = true;
  #     externalInterface = "wlan0";
  #     internalInterfaces = [ "enp2s0" ];
  #   };
  #
  #   # DHCP 서버 활성화 (내부망)
  #   # dhcpcd = {
  #   #   enable = true;
  #   #   allowInterfaces = [ "enp2s0" ];
  #   #   extraConfig = ''
  #   #     subnet 192.168.2.0 netmask 255.255.255.0 {
  #   #       range 192.168.2.100 192.168.2.200;
  #   #       option routers 192.168.2.1;
  #   #     }
  #   #   '';
  #   # };
  # };

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "68bea79acfa612d0"
    ];
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

  # services.upower.enable = true;
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

  # services.zapret.enable = true;
  # services.zapret.params = [
  #   # "--dpi-desync=disorder2"
  #   # "--dpi-desync=fake"
  #   # "--dpi-desync-ttl=1"
  #   # "--dpi-desync-autottl=1"
  #
  #   "--dpi-desync=multidisorder"
  #   "--dpi-desync-split-pos=2"
  # ];

  # services.udev.packages = with pkgs; [
  #   via
  #   vial
  # ];

  # https://discourse.nixos.org/t/removing-persistent-boot-messages-for-a-silent-boot/14835/10
  # Boot
  boot = {
    # Plymouth
    consoleLogLevel = 0;
    loader.timeout = 0;

    initrd.verbose = false;
    plymouth = {
      enable = true;
      # theme = "rings";
      # themePackages = with pkgs; [
      #   # By default we would install all themes
      #   (adi1090x-plymouth-themes.override {
      #     selected_themes = [ "rings" ];
      #   })
      # ];
    };

    kernelParams = [
      "boot.shell_on_fail"
      "i915.enable_fbc=1"
      "i915.enable_guc=3"
      "i915.fastboot=1"

      "intel_pstate=active" # HWP 활성
      "mitigations=off"
      "mitigations=off" # 모든 CPU 취약점 완화 해제
      "nmi_watchdog=0" # NMI 워치독 비활성
      "nowatchdog"
      "nowatchdog" # 하드웨어 워치독 비활성
      # "plymouth.boot-log=/dev/null"
      "quiet" # 부팅 로그 최소화 (미미)
      "random.trust_cpu=on" # RDRAND 신뢰 (부팅 엔트로피 빨리 채움)
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "transparent_hugepage=madvise"
      "tsc=reliable" # TSC 검증 스킵
      "udev.log_priority=3"
    ];
  };

  # systemd.services."xxx" = {
  #   serviceConfig.User = "rok";
  #   serviceConfig.Restart = "always";
  #   serviceConfig.RestartSec = "5s";
  #   # serviceConfig.WorkingDirectory = "/home/rok/src/github.com/investing-kr/bot/cmd/trader-buy-cancel";
  #   wantedBy = [ "network.target" ];
  #   path = [ "/run/current-system/sw" ];
  #   script = "sleep 1000";
  # };

  # services.nebula.networks.rootnet = {
  #   enable = true;
  #   isLighthouse = false;
  #
  #   settings = {
  #     lighthouse = {
  #       hosts = [ "192.168.200.1" ];
  #     };
  #   };
  #   staticHostMap = {
  #     "192.168.200.1" = [
  #       "152.67.199.70:4242"
  #     ];
  #   };
  #
  #   firewall = {
  #     outbound = [{
  #       port = "any";
  #       proto = "any";
  #       host = "any";
  #     }];
  #     inbound = [
  #     {
  #       port = "any";
  #       proto = "any";
  #       host = "any";
  #     }];
  #   };
  #
  #   cert = "/etc/nebula/sm-a556e.crt"; # The name of this lighthouse is beacon.
  #   key = "/etc/nebula/sm-a556e.key";
  #   ca = "/etc/nebula/ca.crt";
  # };

  # systemd.services."simpleone" = {
  #   enable = true;
  #   path = [
  #     "/run/current-system/sw"
  #   ];
  #   script = ''
  #       sleep 1000
  #   '';
  # };

  # systemd.services."sshuttle" = {
  #   enable = true;
  #   path = [
  #     "/run/current-system/sw"
  #     # with this config, /home/rok/bin will be in $PATH, required by pnpm to work
  #     "/home/rok"
  #   ];
  #   script = ''
  #       /home/rok/src/git.internal/work/bin/sshuttle.txxx
  #   '';
  # };

  # https://github.com/nix-community/srvos/blob/main/nixos/server/default.nix#L75
  #
  # Given that our systems are headless, emergency mode is useless.
  # We prefer the system to attempt to continue booting so
  # that we can hopefully still access it remotely.
  boot.initrd.systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
    "emergency.service"
    "emergency.target"
  ];

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    settings.Manager = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 7.5s.
      # If the hardware watchdog does not get a signal for 15s,
      # it will forcefully reboot the system.
      RuntimeWatchdogSec = "30s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      RebootWatchdogSec = "60s";
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      KExecWatchdogSec = "2m";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://hyprland.cachix.org"
        "https://wezterm.cachix.org"
        "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Core C++ runtime (most critical for adb)
    stdenv.cc.cc.lib

    # Compression (adb uses zlib heavily)
    zlib

    # Terminal/console support
    # ncurses

    # USB device access
    # udev

    # Graphics (emulators, SDK tools)
    # libGL
    # libGLU

    # Networking/file access
    # openssl

    # Common utils
    # libuuid
    # dbus.lib

    # 32-bit support (if using older SDKs)
    # gcc.cc.lib32 # uncomment if needed
  ];
}
