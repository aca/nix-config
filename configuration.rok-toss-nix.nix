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

    ./dev/default.nix
    ./dev/data.nix
    ./dev/go.nix
    ./dev/python.nix
    ./dev/lua.nix
    ./dev/go.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  systemd.services = {
    "go-slog" = {
      enable = true;
      path = [];
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        User = "rok";
        Restart = "always";
        ExecStart = ''
          /home/rok/bin/go-slog
        '';
      };
    };
    # "fix-spice-issue" = {
    #   enable = true;
    #   path = [];
    #   wantedBy = ["multi-user.target"];
    #   after = ["network.target"];
    #   serviceConfig = {
    #     Type = "simple";
    #     User = "rok";
    #     Restart = "always";
    #     ExecStart = ''
    #       /home/rok/bin/go-slog
    #
    #     '';
    #   };
    # }
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
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      # firefox
      # pueue
      kate
      #  thunderbird
    ];
  };

  virtualisation.docker.enable = true;

  # virtualisation.podman = {
  #   enable = true; # replace with podman
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

  environment.systemPackages = with pkgs;
    [
      # glfw-wayland
      #
      # pkgs.unstable.nushell
      # glxinfo
    ]
    ++ [
      xorg.libX11
      _9pfs
      bolt
      trash-cli
      # pkgs.unstable.xonsh
      xsel
      clang
      clang-tools_16
      convmv
      cron
      scc
      delta
      xorg.luit
      oracle-instantclient

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
      typst
      virtiofsd
      waypipe
      webkitgtk
      zf
      wev
      wireshark
      pkgs.unstable.ripgrep
      # pkgs.unstable.docker
      pkgs.unstable.deno
      pkgs.unstable.syncthing
      pkgs.unstable.tailscale
      pkgs.unstable.watchexec
      pkgs.unstable.alacritty
      pkgs.unstable.wl-clipboard
      pkgs.unstable.xclip
      pkgs.unstable.kitty

      pkgs.unstable.kotlin-language-server
      xsel
      yarn
      zathura
      zef
      s3fs
      fluent-bit
      vbindiff
      unixtools.xxd

      pkgs.unstable.zls
      pkgs.unstable.zig
      # pkgs.google-chrome
      oracle-instantclient

      (pkgs.unstable.chromium.override {
        commandLineArgs = [
          # "--ozone-platform-hint=auto"
          "--ozone-platform-hint=wayland"
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

      pkgs.unstable.pdm
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
