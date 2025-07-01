# https://nixos.org/guides/njx-pills/
{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}@args:
let
  # inherit (import ./vars.nix) work;
  hostName = "txxx-nix";
in
{
  # systemd.sysusers.enable = true;
  # services.userborn.enable = true; # or systemd.sysuser, required

  # networking.nameservers = [
  #   "1.1.1.1#one.one.one.one"
  #   "1.0.0.1#one.one.one.one"
  # ];
  # security.pki.certificateFiles = [
  #   ./certs/home.internal+1.pem
  # ];

  # services.weechat.enable = true;

  environment.variables.ZK_ROOT = "/home/rok/src/git.internal/zk";
  environment.variables.ZK_LOCAL_ROOT = "/home/rok/src/git.internal/zk/txxx";

  nix.enable = true;

  # services.grafana = {
  #   enable = true;
  #   settings = {
  #     server = {
  #       http_addr = "0.0.0.0";
  #       http_port = 3000;
  #       serve_from_sub_path = true;
  #     };
  #     security.admin_pasword = "admin";
  #   };
  # };

  programs.java.enable = true;
  programs.java.package = pkgs.jdk17;

  services.dnsmasq = {
    enable = true;

    # Forward *everything* to these upstreams

    settings = {
      cache-size = 10000;
      clear-on-reload = true;
      min-cache-ttl = 3600;
      log-queries = true;
      log-dhcp = true;
      server = [
        "8.8.8.8"
      ];
    };

    # # Resolve *.lan on your local subnet via another host
    # extraConfig = ''
    #   server=/lan/192.168.1.1
    #   # Don’t forward “.lan” queries to upstreams:
    #   domain-needed
    #   bogus-priv
    # '';
    #
    # # (optional) Run an internal DHCP server on eth0
    # dhcpServer = {
    #   enable = true;
    #   interface = "eth0";
    #   range = "192.168.1.100,192.168.1.250,12h";
    #   options = { "router" = "192.168.1.1"; };
    # };
  };

  # # Ensure local resolver is used system-wide
  # networking = {
  #   nameservers = [ "127.0.0.1" "::1" ];
  #   # OR, if you use systemd-resolved stub resolver:
  #   # networkmanager.dns = "systemd-resolved";
  # };

  # services.vector.journaldAccess = true;
  # services.vector.enable = true;
  # services.vector.settings = (builtins.fromTOML (builtins.readFile ./vector.toml));

  # users.users.testuser = {
  #   # isNormalUser = false;
  #   isSystemUser = true;
  #   description = "";
  #   group = "testuser";
  #   extraGroups = ["networkmanager" "wheel" "docker" "adbusers" "libvirtd" "libvirt" "syncthing" "matrix-synapse" "cgit"];
  # };

  # systemd.services."xxx" = {
  #     enable = true;
  #     path = [];
  #     wantedBy = ["multi-user.target"];
  #     after = ["network.target"];
  #     serviceConfig = {
  #       Type = "simple";
  #       User = "rok";
  #       Restart = "always";
  #       ExecStart = ''
  #         echo /home/rok/.gitconfig
  #         sleep 10000
  #       '';
  #     };
  # };

  networking.hosts = {
    "100.127.31.30" = [ "git.home.internal" ];
    # "100.115.43.17" = [ ""]
  };

  # disabledModules = ["services/networking/tailscale.nix"];
  # services.prometheus.exporters.node.enable = true;

  services.caddy.enable = false;
  #  services.caddy.virtualHosts."txxx-nix".extraConfig = ''
  # redir https://txxx-nix.folk-uaru.ts.net
  #  '';
  programs.dconf.enable = true;
  services.tailscale.permitCertUid = "caddy";

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      pkgs.fcitx5-mozc
      pkgs.fcitx5-gtk
      pkgs.fcitx5-with-addons
      pkgs.fcitx5-mozc
      pkgs.fcitx5-hangul
      pkgs.fcitx5-lua
      # pkgs.fcitx5-chinese-addons
    ];
  };

  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  # age.secrets.txxx = { file = ./secrets/txxx.age; mode = "777"; };

  age.secrets."env" = {
    file = ./secrets/env.txxx-nix.age;
    mode = "777";
  };
  environment.extraInit = "source ${config.age.secrets."env".path}";

  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  # disabledModules = ["services/networking/tailscale.nix"];

  virtualisation.vmware.guest.enable = true;

  # services.xserver.videoDrivers = [ "vmware" ];

  # disabledModules = ["virtualisation/vmware-guest.nix"];
  imports = [
    # "${args.inputs.nixpkgs-aca}/nixos/modules/services/networking/tailscale.nix"
    # "${args.inputs.nixpkgs-unstable}/nixos/modules/virtualisation/vmware-guest.nix"
    ./pkgs/tmux/tmux.nix
    ./pkgs/i3.nix

    ./env.nix
    ./hardware/txxx-nix.nix
    ./nixos/fonts.nix
    ./pkgs/scripts.nix

    ./dev/nix.nix
    ./dev/c.nix
    ./dev/rust.nix
    ./dev/default.nix
    ./dev/zig.nix
    ./dev/js.nix
    ./dev/data.nix
    ./dev/linux.nix
    ./dev/go.nix
    ./dev/container.nix
    ./dev/python.nix
    ./dev/lua.nix
    ./dev/go.nix
    ./dev/neovim_conf.nix
  ];

  # environment.extraInit = lib.mkAfter ''
  #   export DISPLAY=:0
  # '';

  # Disable wait online as it's causing trouble at rebuild
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.systemd-udevd.restartIfChanged = false;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  # systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Allow unfree packages

  environment.sessionVariables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.oracle-instantclient ];
  };

  # nix.nixPath =
  #   # Prepend default nixPath values.
  #   options.nix.nixPath.default ++
  #   # Append our nixpkgs-overlays.
  #   [ "nixpkgs-overlays=./overlays/" ];

  programs.wireshark = {
    enable = false;
  };

  nixpkgs.overlays = [
    # (import (builtins.fetchTarball {
    #   url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    # }))

    # (final: prev: {
    #   podman = pkgs.unstable.podman;
    # })

    # https://github.com/NixOS/nixpkgs/issues/244159
    # (
    #   let
    #     pinnedPkgs = import
    #       (pkgs.fetchFromGitHub {
    #         owner = "NixOS";
    #         repo = "nixpkgs";
    #         rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
    #         sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
    #       })
    #       { };
    #   in
    #   final: prev: {
    #     docker = pinnedPkgs.docker;
    #   }
    # )
  ];

  system.stateVersion = "25.05";

  networking.hostName = "txxx-nix";
  networking.wireless.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "virtiofs" ];
  boot.kernelPackages = pkgs.linuxPackages_testing;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  #
  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "en_US.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "en_US.UTF-8";
  #   LC_TIME = "en_US.UTF-8";
  # };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=true"
  ];
  services.tailscale.extraDaemonFlags = [ "--socks5-server=0.0.0.0:1080" ];

  # GUI
  # services.xserver.enable = true;
  # services.xserver.displayManager.startx.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # environment.gnome.excludePackages =
  #   (with pkgs; [
  #     gnome-photos
  #     gnome-tour
  #     gnome-themes-extra
  #   ])
  #   ++ (with pkgs.gnome; [
  #     cheese # webcam tool
  #     gnome-disk-utility
  #     gnome-maps
  #     gnome-contacts
  #     gnome-backgrounds
  #     gnome-weather
  #     gnome-autoar
  #     gnome-music
  #     gnome-calculator
  #     gnome-terminal
  #     epiphany # web browser
  #     geary # email reader
  #     evince # document viewer
  #     gnome-characters
  #     totem # video player
  #     tali # poker game
  #     iagno # go game
  #     hitori # sudoku game
  #     atomix # puzzle game
  #   ]);

  # systemd.services."p2p-clipboard" = {
  #     enable = true;
  #     path = [];
  #     wantedBy = ["multi-user.target"];
  #     after = ["network.target"];
  #     environment = {
  #       DISPLAY = ":0";
  #     };
  #     serviceConfig = {
  #       Type = "simple";
  #       User = "rok";
  #       Restart = "always";
  #       ExecStart = ''
  #         /home/rok/bin/p2p-clipboard --connect 100.85.204.31:34853 12D3KooWN5pG6hxtegNe2gYfJFtuFU3vFPidRPHRELtSuzRcpxbB
  #       '';
  #     };
  # };

  # systemd.services."test-signal" = {
  #   enable = true;
  #   path = [];
  #   # wantedBy = ["multi-user.target"];
  #   # after = ["network.target"];
  #   serviceConfig = {
  #     Type = "simple";
  #     Restart = "always";
  #     ExecStartPre = ''
  #       /run/current-system/sw/bin/echo 1
  #       ExecStartPre=-/run/current-system/sw/bin/docker stop --time 5 %n
  #       ExecStartPre=-/run/current-system/sw/bin/docker rm %n
  #       ExecStartPre=/run/current-system/sw/bin/echo 2
  #     '';
  #     Environment = "_SYSTEMD_UNIT=%n";
  #     ExecStart = ''/run/current-system/sw/bin/bash -c "/run/current-system/sw/bin/docker run --name %n ubuntu sleep 10"'';
  #     ExecStop = ''/run/current-system/sw/bin/docker stop --time 5 %n'';
  #   };
  # };

  # microsocks not work
  systemd.services."xep-sleep" = {
    enable = true;
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStart = ''
        /bin/sh -c "echo 1; sleep 120;"
      '';
    };
  };

  # # microsocks not work
  # systemd.services."socks5-proxy" = {
  #   enable = true;
  #   serviceConfig = {
  #     Type = "simple";
  #     Restart = "always";
  #     ExecStart = ''
  #       ${pkgs.microsocks}/bin/microsocks -i 100.80.130.113 -p 1080
  #     '';
  #   };
  # };

  # systemd.services."root-oracle" = {
  #   enable = true;
  #   path = [];
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "rok";
  #     Restart = "always";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/socat -v TCP-LISTEN:1521,fork TCP:home.dory-acoustic.ts.net:1521
  #     '';
  #   };
  # };

  # xserver
  services.xserver.xkb.variant = "";
  services.xserver.xkb.layout = "us";
  services.libinput.enable = true;

  # sound
  # sound.enable = true;
  # hardware.pulseaudio.enable = true; # a2dp not found, enable it, not sure
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   # If you want to use JACK applications, uncomment this
  #   jack.enable = true;
  # };
  services.pipewire.enable = lib.mkForce false;
  services.pulseaudio.enable = lib.mkForce true;
  # hardware.pulseaudio.support32Bit = lib.mkForce true;
  # hardware.pulseaudio.extraConfig = ''
  #   unload-module module-suspend-on-idle
  # '';
  # default-fragments = 2
  # default-fragment-size-msec = 20
  # load-module module-loopback sink=analog latency_msec=65

  # hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.support32Bit = true; ## If compatibility with 32-bit applications is desired.
  # nixpkgs.config.pulseaudio = true;
  # services.pipewire.enable = false;

  # security
  security.rtkit.enable = true;
  security.sudo.enable = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rok = {
    isNormalUser = true;
    description = "rok";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "wireshark"
    ];
    packages = with pkgs; [ ];
  };

  virtualisation.docker.enable = true;
  virtualisation.containers.registries.insecure = [
    "localhost:5000"
    "100.75.184.56:5000"
    "100.85.204.31:5000"
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  # services.xserver.videoDrivers = ["vmware"]; # aarch64 not supported

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # ubuntu_font_family
      noto-fonts
      # noto-fonts-cjk
      noto-fonts-emoji
      # (pkgs.nerdfonts.override { fonts = [ "IosevkaTermSlab" ]; })
      nerd-fonts.iosevka-term-slab
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

  services.openssh.enable = true;
  # services.qemuGuest.enable = true;
  # services.spice-vdagentd.enable = true;
  # services.spice-webdavd.enable = true;

  # services.syncthing = {
  #   enable = true;
  #   user = "rok";
  #   dataDir = "/home/rok"; # Default folder for new synced folders
  #   configDir = "/home/rok/.syncthing"; # Folder for Syncthing's settings and keys
  #   settings = {
  #     gui = {
  #       theme = "black";
  #     };
  #     devices = {
  #       "txxx" = {id = "BMTXVFR-DXR7XUT-TQSN65G-4SPN2SE-Z35J44T-7A4HJEE-6LRI2XT-ZHZS5QF";};
  #       "root" = {id = "D5HADJL-KDECRCV-GPTJ3RE-MPXNFBH-U6KG3CA-LVSDPP2-MT72ETM-RDM77AG";};
  #       "home" = {id = "JIMRCFS-4AQYUPQ-AGCUPAT-D3GK7EN-WZAMSZM-EPSBDHE-PQFWKT5-4DWUMA3";};
  #     };
  #     # folders = {
  #     #   ${(builtins.fromJSON (builtins.readFile config.age.secrets."txxx".path)).workdir} = {
  #     #     path = "/home/rok/src/${(builtins.fromJSON (builtins.readFile config.age.secrets."txxx".path)).workdir}";
  #     #     devices = ["txxx" "home"];
  #     #   };
  #     #   "Downloads" = {
  #     #     path = "/home/rok/Downloads";
  #     #     devices = ["txxx"];
  #     #   };
  #     # };
  #     #
  #   };
  # };

  # services.syncthing.settings.folders = {
  #   "txxx" = {
  #     # Name of folder in Syncthing, also the folder ID
  #     path = "/home/rok/src/txxx"; # Which folder to add to Syncthing
  #     devices = ["home" "root"]; # Which devices to share the folder with
  #   };
  # };

  networking.firewall.enable = false;

  # fileSystems."/home/rok/Downloads".device = "share";
  # fileSystems."/home/rok/Downloads".fsType = "9p";
  # fileSystems."/home/rok/Downloads".options = ["trans=virtio" "-oversion=9p2000.L"];

  # environment.extraInit = ""

  environment.systemPackages =
    with pkgs;
    [
      # jdk17
      nickel
      element-desktop
    ]
    ++ [
      jetbrains.datagrip
      # jetbrains.goland
      # jetbrains.idea-community
      # typst
      elvish
      inetutils
      openssl
      openssh
      _9pfs
      bindfs
      # bolt
      trash-cli
      # pkgs.unstable.xonsh
      xsel
      clang
      gcc
      clang-tools_16
      convmv
      cron
      scc
      delta
      # racket
      xorg.luit

      # xvfb-run
      dig
      dog
      # dunst
      libnotify
      bat
      # xterm
      # helix
      cloud-utils
      dura
      entr
      fish
      wireshark
      cloc
      gh
      glances
      glow
      unzip
      gnuplot
      # pkgs.unstable.vector
      units
      gron

      # git-annex
      # git-annex-utils
      # upx
      hexyl
      imagemagick
      jo
      alacritty
      just
      # pkgs.unstable.kitty
      ko
      krew
      kubernetes-helm
      kubectl
      kubectl-images
      kubectl-node-shell
      kubectl-tree
      stern
      kubectx
      kubetail

      # libreoffice-qt

      lshw
      mpv
      mupdf
      ncdu
      # neovim
      # neovim-nightly
      netcat-gnu
      # nginx
      nixpkgs-fmt
      nmap
      # nodejs_20
      # nodePackages_latest.pnpm
      weechat
      # nodePackages_latest.sql-formatter

      virtualgl

      # xf86-video-vmware
      # ov
      p7zip
      pandoc
      phodav

      # php82
      # php82Packages.composer

      xorg.xhost

      progress
      cmake
      alejandra # nix
      bkt

      qemu
      rakudo
      ruby
      ffmpeg
      socat

      zip
      sqlite-interactive
      sshfs
      sshpass
      tcpdump
      termshark
      # terraform
      confluent-platform # kafka tools
      # texlive.combined.scheme-full
      tshark
      # typst
      # typst-lsp
      ledger
      hledger
      # typstfmt
      sublime-merge
      virtiofsd
      zf
      ripgrep
      docker-client
      deno
      tailscale
      watchexec
      wl-clipboard
      xclip
      # pkgs.unstable.kitty

      xsel
      yarn
      zathura
      zef
      s3fs
      vbindiff
      goconvey
      inetutils
      _9pfs
      unixtools.xxd

      vector

      oracle-instantclient

      # (pkgs.unstable.vivaldi.override {
      #   # mesa = pkgs.mesa;
      #   commandLineArgs = [
      #     # "--ozone-platform-hint=wayland"
      #
      #     "--user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36'"
      #     # "--ozone-platform-hint=auto"
      #     # "--enable-features=UseOzonePlatform"
      #     # "--ozone-platform-hint=''"
      #     #
      #     # vmware
      #     "--enable-font-antialiasing"
      #     "--disable-gpu"
      #
      #     # "--ozone-platform=''"
      #
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9223"
      #     # "--force-dark-mode"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #     # "--disable-features=UseOzonePlatform"
      #     # "--gtk-version=4" # fcitx
      #   ];
      # })

      (chromium.override {
        commandLineArgs = [
          # "--ozone-platform-hint=wayland"

          # "--ozone-platform-hint=auto"
          # "--enable-features=UseOzonePlatform"
          # "--ozone-platform-hint=''"
          # "--ozone-platform=''"
          # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36
          "--user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/130.0.2849.80'"
          "--enable-quic"
          "--enable-zero-copy"
          "--remote-debugging-port=9222"
          "--enable-features=WebContentsForceDark"
          "--force-dark-mode"

          # NOTES: ozone-platform=wayland fcitx win+space not work
          # "--disable-features=UseOzonePlatform"
          # "--gtk-version=4" # fcitx
        ];
      })

      # x2goclient
      go-audit
      # audit

      # zig
      # zls
      # telegram-desktop
      # chezmoi
      fuse3
      xournalpp
      kotlin
      kotlin-language-server
      # ripgrep-all
      # jdk23
      # valgrind
      # fuse-common
      # thunderbird
      waypipe
      # cgit
      # fcgiwrap
      caddy
      # flatbuffers

      # (pkgs.unstable.microsoft-edge.override {
      #   commandLineArgs = [
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9227"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #   ];
      # })
      # nyxt

      esbuild
      pavucontrol
      # firefox
      neovim-unwrapped

      # geekbench
      gradle_7
      janet

      amazon-q-cli
      libreoffice-qt
      # pulumi
      # openjdk23
    ];

  virtualisation.docker = {
    enable = true; # replace with podman
    # package = pkgs.docker;
    daemon.settings = {
      # hosts = ["tcp://127.0.0.1:2375"];
      # hosts = ["tcp://0.0.0.0:2375"];
      # insecure-registries = import ./dev/docker.insecure-registries.nix;
    };
  };
}
