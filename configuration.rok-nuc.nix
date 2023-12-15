# httpr://nixos.org/guides/nix-pills/
{
  config,
  pkgs,
  options,
  lib,
  ...
}: {
  imports = [
    ./hardware/rok-nuc.nix
    ./pkgs/sway.nix
  ];

  users.users.rok.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = ["rok"];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.logind.lidSwitch = "ignore";

  nixpkgs.config.allowUnfree = true;

  # programs.adb.enable = true;
  programs.fish.enable = true;

  networking.hostName = "rok-nuc";
  networking.wireless.iwd.enable = true;
  # services.udev.packages = with pkgs; [via vial];
  # KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  # services.udev.extraRules = ''
  #   KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  # '';

  # NOTES: When public wifi doesn't work, comment all dns config and use default dns configuration on network
  # networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
  # services.resolved = {
  #   enable = true;
  #   dnssec = "false";
  #   domains = ["~."];
  #   fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
  #   # extraConfig = ''
  #   #   DNSOverTLS=yes
  #   # '';
  #   extraConfig = ''
  #     DNSOverTLS=false
  #   '';
  # };

  systemd.timers."qbittorrent-clean" = {
    wantedBy = ["timers.target"];
    enable = true;
    timerConfig = {
      OnBootSec = "3m";
      OnUnitActiveSec = "3m";
      Unit = "qbittorrent-clean.service";
    };
  };

  systemd.services."qbittorrent-clean" = {
    path = [pkgs.bash pkgs.curl pkgs.jq pkgs.findutils];
    enable = false;
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/home/rok/.bin/qbittorrent-clean";
    };
  };

  systemd.services."qbittorrent-nox" = {
    enable = false;
    path = [pkgs.qbittorrent-nox];
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      Type = "exec";
      User = "rok";
      ExecStart = ''
        /run/current-system/sw/bin/qbittorrent-nox
      '';
    };
  };

  # services.cockpit.enable = false;

  # "waiter" = {
  #   enable = true;
  #   path = [ pkgs.bash ];
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "notify";
  #     ExecStart = ''
  #       /home/rok/bin/waiter
  #     '';
  #   };
  # };

  # doesn't work for udp trackers
  # https://github.com/qbittorrent/qBittorrent/issues/18970
  # https://github.com/qbittorrent/qBittorrent/issues/7838
  # "proxy-socks5" = {
  #   enable = true;
  #   path = [ ];
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "rok";
  #     Restart = "always";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/ssh -D 1337 -q -C root@oci-xnzm1001-002 "sh -c 'sleep 24h; echo 1'"
  #     '';
  #   };
  # };
  # "qbittorrent-reschedule" = {
  #   path = [pkgs.bash pkgs.curl pkgs.jq pkgs.findutils];
  #   enable = true;
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #     ExecStart = "/home/rok/.bin/qbittorrent-reschedule";
  #   };
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["virtiofs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = ["nfs" "ntfs"];
  services.rpcbind.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # virt-manager
  programs.dconf.enable = true;

  # Enable secure boot and TPM for VMs
  # virtualisation.libvirtd.enable = true;
  # virtualisation.libvirtd.qemu.swtpm.enable = true;
  # virtualisation.libvirtd.qemu.ovmf.enable = true;
  # virtualisation.libvirtd.qemu.ovmf.packages = [pkgs.OVMFFull.fd];
  # virtualisation.spiceUSBRedirection.enable = true;
  # services.spice-vdagentd.enable = true;

  # network
  networking.networkmanager.enable = true;
  # networking.useNetworkd = false;
  # networking.useDHCP = false;

  # Disable wait online as it's causing trouble at rebuild
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.systemd-udevd.restartIfChanged = false;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  systemd.network.enable = false;
  # systemd.network.networks = {
  #   "wlan0" = {
  #     matchConfig.Name = "wlp0s20f3";
  #     networkConfig.DHCP = "yes";
  #     dhcpV4Config.RouteMetric = 2;
  #   };
  #   "eno1" = {
  #     matchConfig.Name = "eno1";
  #     networkConfig.DHCP = "yes";
  #     dhcpV4Config.RouteMetric = 1;
  #   };
  # };

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      pkgs.unstable.fcitx5-mozc
      pkgs.unstable.fcitx5-gtk
      pkgs.unstable.fcitx5-with-addons
      # pkgs.unstable.fcitx5-qt
      # pkgs.unstable.fcitx5-chinese-addons
      pkgs.unstable.fcitx5-hangul
      # pkgs.unstable.fcitx5-lua
    ];
  };

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

  services.upower.enable = true;
  services.fwupd.enable = true;
  # services.qbittorrent.enable = true;
  # services.qbittorrent.port = 4321;

  # security
  security.rtkit.enable = true;
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
    extraGroups = ["networkmanager" "wheel" "docker" "adbusers" "libvirtd"];
    packages = with pkgs; [];
  };

  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  #   }))
  #
  #   # https://discourse.nixos.org/t/how-to-install-version-of-a-package-that-is-newer-then-in-nixpkgs/16450/4
  #   # NOTES:(aca) doesn't work, things that depends on go compiler breaks
  #   # (self: super: {
  #   #   go = super.go.overrideAttrs (old: {
  #   #     version = "1.21.0";
  #   #     src = pkgs.fetchurl {
  #   #       url = "https://go.dev/dl/go1.21.0.src.tar.gz";
  #   #       hash = "sha256-gY1G7ehWgt1VGtN47zek0kcAbxLsWbW3VWAdLOEUNpo=";
  #   #     };
  #   #   });
  #   # })
  #
  #   (
  #     let
  #       pinnedPkgs = import
  #         (pkgs.fetchFromGitHub {
  #           owner = "NixOS";
  #           repo = "nixpkgs";
  #           rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
  #           sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
  #         })
  #         { };
  #     in
  #     final: prev: {
  #       docker = pinnedPkgs.docker;
  #     }
  #   )
  # ];

  #   (
  #     let
  #       pinnedPkgs = import
  #         (pkgs.fetchFromGitHub {
  #           owner = "NixOS";
  #           repo = "nixpkgs";
  #           rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
  #           sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
  #         })
  #         { };
  #     in
  #     final: prev: {
  #       docker = pinnedPkgs.docker;
  #     }
  #   )
  # ];

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
  # ];

  hardware.bluetooth.enable = true;
  # virtualisation.docker = {
  #   enable = false;
  #   # package = unstable.docker;
  # };

  # programs.firefox.nativeMessagingHosts.tridactyl = true;
  #

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # List packages installed in system profile. To search, run:
  #
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      glxinfo
      pkgs.unstable.e2fsprogs #nvme
    ]
    ++ [
    ]
    ++ [
      # (import ./packages/sublime-merge/default.nix)
      # (import ./packages/hello/hello.nix)
      (import ./pkgs/advcpmv/default.nix)
    ]
    ++ [
      # cloud
      # pkgs.unstable.awscli2
      # pkgs.unstable.azure-cli
      # azure-storage-azcopy
      # pkgs.unstable.oci-cli
    ]
    ++ [
      # cloud.k8s
      # kubectl
      # stern
      # kubectl-images
      # kubectl-node-shell
      # kubectl-tree
      # kubectx
      # kubetail
      #
      # dive
      #
      # ko
      # krew
    ]
    ++ [
      # laptop
      upower
    ]
    ++ [
      # system
      glances
      htop
      iftop
      # spice-vdagent
      # usbutils
    ]
    ++ [
      # android
      # pkgs.unstable.android-tools
      # pkgs.unstable.android-studio
      # pkgs.unstable.android-udev-rules
      # pkgs.unstable.flutter
      # jdk11
    ]
    ++ [
      # tools
      # via
      # vial

      # pkgs.unstable.gimp
      # pkgs.unstable.virt-manager
      # pkgs.unstable.virt-viewer
      # pkgs.unstable.spice
      # pkgs.unstable.spice-gtk
      # pkgs.unstable.spice-protocol
      # pkgs.unstable.win-virtio
      # pkgs.unstable.win-spice

      # pkgs.unstable.cockpit
    ]
    ++ [
      # browser
      # pkgs.unstable.chromium
      # pkgs.unstable.microsoft-edge
      # pkgs.unstable.google-chrome
      # https://github.com/fcitx/fcitx5/issues/862
      # pkgs.unstable.google-chrome

      (pkgs.unstable.google-chrome.override {
        commandLineArgs = [
          # "--ozone-platform-hint=auto"
          # "--ozone-platform-hint=wayland"
          # "--enable-features=UseOzonePlatform"
          # "--ozone-platform-hint=''"
          # "--ozone-platform=''"

          # "--enable-features=WebContentsForceDark"
          # "--enable-quic"
          # "--enable-zero-copy"
          # "--remote-debugging-port=9222"
          # "--force-dark-mode"
          # NOTES: ozone-platform=wayland fcitx win+space not work
          # "--disable-features=UseOzonePlatform"
          # "--gtk-version=4" # fcitx
        ];
      })
    ]
    ++ [
      # pkgs.unstable.quickemu

      # browser
      # pkgs.unstable.nodejs
      # pkgs.unstable.node2nix
      # pkgs.unstable.nodePackages_latest.node-gyp
      # pkgs.unstable.nodePackages_latest.pnpm
      # # pkgs.unstable.nodePackages_latest.tree-sitter-cli
      # # pkgs.unstable.nodePackages_latest."@vtsls/language-server"
      # pkgs.unstable.nodePackages_latest.pyright
      # pkgs.unstable.nodePackages_latest.fx
      # pkgs.unstable.nodePackages_latest.prettier
      # pkgs.unstable.nodePackages_latest.yaml-language-server
      # pkgs.unstable.nodePackages_latest.vscode-langservers-extracted

      # nodePackages_latest.fx
      # nodePackages_latest.prettier
      # nodePackages.yaml-language-server
      # nodePackages.vscode-langservers-extracted

      # pkgs.unstable.bun
      # pkgs.unstable.deno

      # formatter
      # pkgs.unstable.alejandra # nix
      # pkgs.unstable.gofumpt # go
      # pkgs.unstable.gotools # go
      # pkgs.unstable.gotests
      # # pkgs.unstable.golines
      # pkgs.unstable.isort
      # pkgs.unstable.shfmt
      # pkgs.unstable.taplo
      # pkgs.unstable.yamlfmt
      # pkgs.unstable.beautysh
      # pkgs.unstable.buf
      # pkgs.unstable.black
      # pkgs.unstable.cmake-format
    ]
    ++ [
      # pup
      socat
      # sops
      sqlite
      sshfs
      # sublime-merge
      # git-cola
      sshpass
      telegram-desktop
      libnotify
      lsof
      pv

      # clipboard-jh
      xorg.libX11
    ]
    ++ [
      # pkgs.unstable.qt5
      dig
      inetutils
      wget
      entr
      diskus
      # pcmanfm
      zsh
      xsel
      # gdb
      # _9pfs
      age
      aria2
      atool
      bat
      # bolt
      # ov
      cron
      delta
      ipset
      dig
      # hyperfine
      oauth2-proxy
      direnv
      # glow
      # pkgs.unstable.docker
      # dog
      # pkgs.unstable.nixpkgs-fmt
      desktop-file-utils
      # pandoc
      # pkgs.unstable.dura

      pkgs.unstable.qbittorrent-nox
      (pkgs.makeDesktopItem {
        name = "qbittorrent-nox";
        desktopName = "qbittorrent-nox";
        exec = "/run/current-system/sw/bin/qbittorrent-nox %u";
        mimeTypes = ["x-scheme-handler/magnet" "application/x-bittorrent"];
        # icon = "nix-snowflake";
      })

      gptfdisk

      # appimage-run
      # pkgs.unstable.qemu
      # libguestfs
      unrar

      trash-cli
      webkitgtk
      git-annex-utils
      gnuplot
      gron
      nfs-utils
      helm
      # transmission
      # transmission-remote-gtk
      hexyl
      libisoburn
      flex
      bison
      ncurses
      jo
      asciinema
      just
      # pkgs.unstable.kitty
      # pkgs.unstable.wezterm
      # cmatrix
      # texlive.combined.scheme-full

      # grex
      # gperf
      # libreoffice-qt
      # lnav
      lshw
      # pkgs.unstable.ffmpeg_6-full
      # pkgs.unstable.ffmpeg-full
      # pkgs.mpv-unwrapped
      ncdu
      # pkgs.unstable.neovim
      # neovim-nightly
      # neovim-nightly
      # neovim-nightly
      pkgs.unstable.neovim
      netcat-gnu
      nginx
      nnn
      okular
      p7zip
      unzip
      phodav
      progress
      (luajit.withPackages (p:
        with p; [
          stdlib
        ]))
      # rakudo

      # tcpdump
      # nmap
      # termshark
      # tshark
      # wireshark

      # terraform
      # tig
      # virtiofsd
      # watchexec
      # wev
      # pkgs.unstable.typst
      # pkgs.unstable.yarn
      # pkgs.unstable.zathura
      # zef
      # patchelf
      # ttyd
      # powertop
      # gptfdisk
      # zip

      # pkgs.unstable.zig

      # video
      # rav1e
      #
      # xxHash

      # sway stuff
      pkgs.unstable.sway
      pkgs.unstable.xdragon
      pkgs.unstable.alacritty # gpu accelerated terminal
      # pkgs.unstable.dbus-sway-environment
      pkgs.unstable.rofi-wayland
      pkgs.unstable.wayland
      # pkgs.unstable.rustc
      pkgs.unstable.cargo
      pkgs.unstable.wdisplays
      pkgs.unstable.xdg-utils
      pkgs.unstable.waypipe
      pkgs.unstable.wl-clipboard # clipboard
      pkgs.unstable.xdg-utils # for opening default programs when clicking links
      pkgs.unstable.dunst
      pkgs.unstable.glib # gsettings
      pkgs.unstable.dracula-theme # gtk theme
      pkgs.unstable.gnome3.adwaita-icon-theme # default gnome cursors
      pkgs.unstable.swaylock
      pkgs.unstable.pavucontrol
      pkgs.unstable.swayidle
      pkgs.unstable.pulseaudio
      pkgs.unstable.grim # screenshot functionality
      pkgs.unstable.slurp # screenshot functionality
      pkgs.unstable.bemenu # wayland clone of dmenu
      pkgs.unstable.mako # notification system developed by swaywm maintainer
      pkgs.unstable.wdisplays # tool to configure displays
      pkgs.unstable.kanshi

      pkgs.unstable.syncthing
      pkgs.unstable.tailscale
      pkgs.unstable.mupdf
      pkgs.unstable.pueue
      pkgs.unstable.helix
      pkgs.unstable.gh

      woeusb

      gcc
      gettext
      killall
      pkgs.unstable.git
      pkgs.unstable.fzf
      pkgs.unstable.tmux
      pkgs.unstable.jq
      pkgs.unstable.dasel
      pkgs.unstable.miller
      pkgs.unstable.fd
      pkgs.unstable.ripgrep
      pkgs.unstable.elvish
      inetutils
      wget
      coreutils-full
      findutils
      moreutils
      glibcLocales
      pkgs.unstable.vifm
      ghq
      stow
      gnumake
      procps
      procs
      pkgs.unstable.fish
      pkgs.unstable.vim
      # pkgs.unstable.jetbrains.idea-community
      ninja
      meson
      pkg-config
      lua
      stylua
      # pkgs.unstable.sumneko-lua-language-server
      # waypipe
      # wl-clipboard
      # xsel
      entr
      diskus
      zsh
      # htop
      cmake
      pkgs.unstable.bkt
      pkgs.unstable.go
      # pkgs.unstable.nix-tree
      # pkgs.unstable.pdm
      # (
      #   pkgs.unstable.python3.withPackages (ps:
      #     with ps; [
      #       requests
      #       # boto3
      #       # pyyaml
      #       # yt-dlp
      #       # pandas
      #       # numpy
      #     ])
      # )
    ];

  services.tailscale.enable = true;

  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  services.syncthing = {
    enable = true;
    user = "rok";
    dataDir = "/home/rok"; # Default folder for new synced folders
    configDir = "/home/rok/.syncthing"; # Folder for Syncthing's settings and keys
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = false;
    allowedTCPPortRanges = [
      {
        from = 4180;
        to = 4180;
      }
      {
        from = 2049;
        to = 2049;
      }
      {
        from = 8080;
        to = 8080;
      }
      {
        from = 5357;
        to = 5357;
      } # samba
    ];
    allowedUDPPortRanges = [
      {
        from = 3702;
        to = 3702;
      } # samba
    ];
    allowPing = true;
  };

  # services.samba.openFirewall = true;
  # services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  # services.samba = {
  #   enable = true;
  #   securityType = "user";
  #   extraConfig = ''
  #     workgroup = WORKGROUP
  #     server string = smbnix
  #     netbios name = smbnix
  #     security = user
  #     #use sendfile = yes
  #     #max protocol = smb2
  #     # note: localhost is the ipv6 localhost ::1
  #     hosts allow = 192.168.0. 127.0.0.1 192.168.122. localhost
  #     hosts deny = 0.0.0.0/0
  #     guest account = nobody
  #     map to guest = bad user
  #   '';
  #   shares = {
  #     win11 = {
  #       path = "/home/rok/mnt/win11";
  #       browseable = "yes";
  #       "read only" = "no";
  #       "guest ok" = "yes";
  #       "create mask" = "0644";
  #       "directory mask" = "0755";
  #       "force user" = "rok";
  #       "force group" = "users";
  #     };
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # systemd.user.services.pueued = {
  #   path = [ pkgs.pueue ];
  #   enable = false;
  #   serviceConfig.ExecStart = "${pkgs.pueue}/bin/pueued";
  # };

  # fonts = {
  #   enableDefaultFonts = true;
  #   fonts = with pkgs; [
  #     noto-fonts
  #     noto-fonts-cjk
  #     noto-fonts-emoji
  #     iosevka
  #     iosevka-comfy.comfy
  #     iosevka-comfy.comfy-duo
  #     iosevka-comfy.comfy-fixed
  #     iosevka-comfy.comfy-motion
  #     nanum
  #   ];
  #
  #   fontconfig = {
  #     defaultFonts = {
  #       serif = ["NanumGothic" "Noto Sans Mono"];
  #       sansSerif = ["NanumGothic" "Noto Sans Mono"];
  #       monospace = ["Noto Sans Mono"];
  #     };
  #   };
  # };

  # fileSystems."/export/Downloads" = {
  #   device = "/home/rok/Downloads";
  #   options = ["bind"];
  # };

  services.nfs.server.enable = true;
  # /export       192.168.0.0/24(rw,fsid=0,no_subtree_check)
  services.nfs.server.exports = ''
    /home/rok/Downloads 192.168.0.0/24(rw,nohide,insecure,no_subtree_check) 192.168.122.0/24(rw,nohide,insecure,no_subtree_check)
    /home/rok/mnt/nuc 192.168.0.0/24(rw,nohide,insecure,no_subtree_check) 192.168.122.0/24(rw,nohide,insecure,no_subtree_check)
    /home/rok/mnt/sdb1 192.168.0.0/24(rw,nohide,insecure,no_subtree_check) 192.168.122.0/24(rw,nohide,insecure,no_subtree_check)
    /home/rok/mnt/sdc1 192.168.0.0/24(rw,nohide,insecure,no_subtree_check) 192.168.122.0/24(rw,nohide,insecure,no_subtree_check)
    /home/rok/mnt/sdd1 192.168.0.0/24(rw,nohide,insecure,no_subtree_check) 192.168.122.0/24(rw,nohide,insecure,no_subtree_check)
    /home/rok/mnt/sde1 192.168.0.0/24(rw,nohide,insecure,no_subtree_check) 192.168.122.0/24(rw,nohide,insecure,no_subtree_check)
  '';
}
