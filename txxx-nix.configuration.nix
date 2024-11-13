# https://nixos.org/guides/njx-pills/
{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
} @ args: let
  # inherit (import ./vars.nix) work;
  hostName = "txxx-nix";
in {
  # disabledModules = ["services/networking/tailscale.nix"];
  # services.prometheus.exporters.node.enable = true;

  services.caddy.enable = true;
  # services.caddy.virtualHosts."localhost".extraConfig = ''
  #   reverse_proxy http://localhost:8888
  # '';

  age.identityPaths = ["/home/rok/.ssh/id_ed25519"];
  # age.secrets.txxx = { file = ./secrets/txxx.age; mode = "777"; };

  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  imports = [
    # "${args.inputs.nixpkgs-aca}/nixos/modules/services/networking/tailscale.nix"
    ./pkgs/scripts.nix
    ./pkgs/tmux.nix

    ./env.nix
    ./hardware/txxx-nix.nix
    ./nixos/fonts.nix

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
  ];

  environment.extraInit = lib.mkAfter ''
    export DISPLAY=:0
  '';

  # systemd.services.systemd-udevd.restartIfChanged = false;
  # Disable wait online as it's causing trouble at rebuild
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "nix-2.16.2"
  ];

  # Allow unfree packages

  # environment.sessionVariables = {
  #   LD_LIBRARY_PATH = lib.makeLibraryPath oracle-insta;
  # };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # nix.nixPath =
  #   # Prepend default nixPath values.
  #   options.nix.nixPath.default ++
  #   # Append our nixpkgs-overlays.
  #   [ "nixpkgs-overlays=./overlays/" ];

  environment.sessionVariables = rec {
    # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [pkgs.oracle-instantclient];
    NIXPKGS_ALLOW_UNFREE = "1";
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

  system.stateVersion = "24.05";
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = ["rok"];
  };

  networking.hostName = "txxx-nix";

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.initrd.availableKernelModules = ["virtiofs"];
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true"];

  # GUI
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
#   displayManager = { 
#   defaultSession = "none+i3"; 
#   lightdm = { 
#     enable = true; 
#     greeter.enable = false; 
#     autoLogin = { 
#       enable = true; 
#       user = "dooy"; 
#     }; 
#   }; 
# };
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-themes-extra
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-disk-utility
      gnome-maps
      gnome-contacts
      gnome-backgrounds
      gnome-weather
      gnome-autoar
      gnome-music
      gnome-calculator
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);

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
  systemd.services."socks5-proxy" = {
    enable = true;
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStart = ''
        ${pkgs.microsocks}/bin/microsocks -i 100.80.130.113 -p 1080
      '';
    };
  };

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
  sound.enable = true;
  # hardware.pulseaudio.enable = true; # a2dp not found, enable it, not sure
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   # If you want to use JACK applications, uncomment this
  #   #jack.enable = true;
  # };

  # security
  security.rtkit.enable = true;
  security.sudo.enable = true;
  security.sudo.extraRules = [
    {
      users = ["rok"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rok = {
    isNormalUser = true;
    description = "rok";
    extraGroups = ["networkmanager" "wheel" "docker" "wireshark"];
    packages = with pkgs; [
      # (
      #   pkgs.stdenvNoCC.mkDerivation {
      #     name = "gillsans-font";
      #     dontConfigue = true;
      #     src = pkgs.fetchzip {
      #       url = "https://freefontsvault.s3.amazonaws.com/2020/02/Gill-Sans-Font-Family.zip";
      #       sha256 = "sha256-YcZUKzRskiqmEqVcbK/XL6ypsNMbY49qJYFG3yZVF78=";
      #       stripRoot = false;
      #     };
      #     installPhase = ''
      #       mkdir -p $out/share/fonts
      #       cp -R $src $out/share/fonts/opentype/
      #     '';
      #     meta = {description = "A Gill Sans Font Family derivation.";};
      #   }
      # )
      # # firefox
      # # pueue
      # kate
      # #  thunderbird
    ];
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

  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;

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
  #       "rok-txxx" = {id = "BMTXVFR-DXR7XUT-TQSN65G-4SPN2SE-Z35J44T-7A4HJEE-6LRI2XT-ZHZS5QF";};
  #       "root" = {id = "D5HADJL-KDECRCV-GPTJ3RE-MPXNFBH-U6KG3CA-LVSDPP2-MT72ETM-RDM77AG";};
  #       "home" = {id = "JIMRCFS-4AQYUPQ-AGCUPAT-D3GK7EN-WZAMSZM-EPSBDHE-PQFWKT5-4DWUMA3";};
  #     };
  #     # folders = {
  #     #   ${(builtins.fromJSON (builtins.readFile config.age.secrets."txxx".path)).workdir} = {
  #     #     path = "/home/rok/src/${(builtins.fromJSON (builtins.readFile config.age.secrets."txxx".path)).workdir}";
  #     #     devices = ["rok-txxx" "home"];
  #     #   };
  #     #   "Downloads" = {
  #     #     path = "/home/rok/Downloads";
  #     #     devices = ["rok-txxx"];
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

  environment.systemPackages = with pkgs;
    [
      # jdk17
    ]
    ++ [
      elvish
      inetutils
      openssl
      openssh
      xorg.libX11
      _9pfs
      bindfs
      bolt
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
      racket
      xorg.luit

      xvfb-run
      dig
      # direnv
      dog
      # dunst
      libnotify
      bat
      helix
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
      helm

      # git-annex
      # git-annex-utils
      upx
      hexyl
      imagemagick
      jo
      just
      # pkgs.unstable.kitty
      ko
      krew
      kubectl
      kubectl-images
      kubectl-node-shell
      kubectl-tree
      stern
      kubectx
      kubetail

      libreoffice-qt

      lshw
      mpv
      mupdf
      ncdu
      # neovim
      # neovim-nightly
      netcat-gnu
      nginx
      nixpkgs-fmt
      nmap
      nodejs_20
      nodePackages_latest.pnpm
      nodePackages_latest.sql-formatter

      okular
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
      # typstfmt
      virtiofsd
      zf
      ripgrep
      docker-client
      deno
      syncthing
      tailscale
      watchexec
      wl-clipboard
      xclip
      # pkgs.unstable.kitty

      jdt-language-server
      kotlin-language-server
      xsel
      yarn
      zathura
      qemu
      zef
      s3fs
      fluent-bit
      vbindiff
      goconvey
      inetutils
      _9pfs
      unixtools.xxd

      vector

      # pkgs.unstable.zls
      # pkgs.unstable.zig
      # pkgs.google-chrome
      oracle-instantclient

      (chromium.override {
        commandLineArgs = [
          # "--ozone-platform-hint=wayland"

          # "--ozone-platform-hint=auto"
          # "--enable-features=UseOzonePlatform"
          # "--ozone-platform-hint=''"
          # "--ozone-platform=''"

          "--enable-features=WebContentsForceDark"
          "--enable-quic"
          "--enable-zero-copy"
          "--remote-debugging-port=9222"
          "--force-dark-mode"
          # NOTES: ozone-platform=wayland fcitx win+space not work
          # "--disable-features=UseOzonePlatform"
          # "--gtk-version=4" # fcitx
        ];
      })

      x2goclient

      chezmoi
      fuse3
      fuse-common

      cgit
      fcgiwrap
      caddy
    ];
}
