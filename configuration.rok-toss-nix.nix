# https://nixos.org/guides/njx-pills/
{
  config,
  pkgs,
  options,
  ...
}: {
  imports = [
    ./hardware/rok-toss-nix.nix
    ./nixos/fonts.nix
    # ./pkgs/sway.nix

    ./dev/c.nix
    ./dev/default.nix
    ./dev/data.nix
    ./dev/linux.nix
    ./dev/go.nix
    ./dev/python.nix
    ./dev/lua.nix
    ./dev/go.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "nix-2.16.2"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [pkgs.oracle-instantclient];
  };

  programs.wireshark = {
    enable = true;
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))

    (final: prev: {
      podman = pkgs.unstable.podman;
    })

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

  system.stateVersion = "23.11";
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = ["rok"];
  };

  networking.hostName = "rok-toss-nix";
  networking.wireless.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["virtiofs"];

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

  # GUI
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
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
      gedit # text editor
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

  systemd.services."p2p-clipboard" = {
      enable = true;
      path = [];
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        User = "rok";
        Restart = "always";
        ExecStart = ''
          /home/rok/bin/p2p-clipboard --connect 100.85.204.31:34853 12D3KooWN5pG6hxtegNe2gYfJFtuFU3vFPidRPHRELtSuzRcpxbB
        '';
      };
  };

  systemd.services."root-oracle" = {
      enable = true;
      path = [];
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        User = "rok";
        Restart = "always";
        ExecStart = ''
          /run/current-system/sw/bin/socat -v TCP-LISTEN:1521,fork TCP:100.85.204.31:1521
        '';
      };
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

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
      # firefox
      # pueue
      kate
      #  thunderbird
    ];
  };

  virtualisation.docker.enable = true;
  virtualisation.containers.registries.insecure = [
    "localhost:5000"
    "100.75.184.56:5000"
    "100.85.204.31:5000"
  ];

  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  # };

  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;

  services.syncthing = {
    enable = true;
    user = "rok";
    dataDir = "/home/rok"; # Default folder for new synced folders
    configDir = "/home/rok/.syncthing"; # Folder for Syncthing's settings and keys
  };

  networking.firewall.enable = false;

  # environment.extraInit = ""

  environment.systemPackages = with pkgs;
    [
      # glfw-wayland
      #
      # pkgs.unstable.nushell
      # glxinfo
    ]
    ++ [
      # kubedock
      inetutils
      openssl
      openssh
      xorg.libX11
      _9pfs
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
      xorg.luit

      dig
      direnv
      dog
      # dunst
      libnotify
      pkgs.unstable.bat
      pkgs.unstable.helix
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
      pkgs.unstable.yazi
      pkgs.unstable.git-annex
      git-annex-utils
      upx
      pkgs.unstable.kakoune
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
      neovim-nightly
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
      pkgs.unstable.alejandra # nix
      pkgs.unstable.bkt

      qemu
      rakudo
      ruby
      socat
      # pkgs.unstable.spice-vdagent
      # spice-vdagent

      sqlite-interactive
      sshfs
      sshpass
      tcpdump
      termshark
      terraform
      texlive.combined.scheme-full
      tshark
      # typst
      # typst-lsp
      # typstfmt
      virtiofsd
      waypipe
      webkitgtk
      zf
      wev
      pkgs.unstable.ripgrep
      # pkgs.unstable.docker
      pkgs.unstable.docker-client
      pkgs.unstable.deno
      pkgs.unstable.syncthing
      pkgs.unstable.tailscale
      pkgs.unstable.watchexec
      pkgs.unstable.alacritty
      # pkgs.unstable.alacritty
      pkgs.unstable.wl-clipboard
      pkgs.unstable.xclip
      pkgs.unstable.kitty

      jdt-language-server
      pkgs.unstable.kotlin-language-server
      xsel
      yarn
      zathura
      zef
      s3fs
      fluent-bit
      vbindiff
      unstable.goconvey
      inetutils
      unixtools.xxd

      pkgs.unstable.vector

      # pkgs.unstable.zls
      # pkgs.unstable.zig
      # pkgs.google-chrome
      oracle-instantclient

      (pkgs.unstable.chromium.override {
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

      # pkgs.unstable.pdm
      (
        pkgs.unstable.python3.withPackages (ps:
          with ps; [
            requests
            boto3
            pyyaml
            yt-dlp
            ptpython

            # linux dbus related
            dbus-python
            pygobject3

            # pandas
            # numpy
          ])
      )

      fuse3
      fuse-common
    ];
}
