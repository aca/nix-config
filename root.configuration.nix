# https://nixos.org/guides/nix-pills/
{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}@args:
let
  hostName = "root";
in
{
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  networking.hostName = hostName;
  networking.wireless.iwd.enable = true;
  networking.extraHosts = (import ./local.nix).networking.extraHosts;

  services.udev.packages = with pkgs; [
    via
    vial
  ];

  services.gnome.gnome-keyring.enable = true;

  # programs.hyprland.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # imports = [
  #   "${inputs.nixpkgs-aca}/nixos/modules/services/networking/tailscale.nix"
  # ];
  imports = [
    ./env.nix
    ./desktop.linux.nix

    ./desktop.nix
    ./pkgs/video.nix
    # ./pkgs/qbittorrent.nix

    ./pkgs/sway/sway.nix

    ./pkgs/nix-alien.nix

    ./dev/data.nix
    ./dev/java.nix
    ./dev/default.nix
    ./dev/go.nix
    ./dev/container.nix
    ./dev/zig.nix
    ./dev/rust.nix
    ./dev/lua.nix
    ./dev/js.nix
    ./dev/python.nix
    ./dev/nix.nix

    ./dev/python.nix

    ./dev/nix.nix

    # ./pkgs/reboot-if-offline.nix
    # ./pkgs/reboot-everyday.nix

    ./hardware/root.nix
  ];

  services.grafana = {
    enable = false;
    settings.server.http_port = 9000;
    settings.server.http_addr = "127.0.0.1";
  };

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  services.prometheus = {
    enable = false;
    port = 9001;
    # scrapeConfigs = [
    #   {
    #     job_name = "oci-xnzm-001";
    #     static_configs = [
    #       {
    #         targets = ["100.79.222.108:9100"];
    #       }
    #     ];
    #   }
    # ];
  };

  services.logind.lidSwitch = "ignore";

  programs.adb.enable = true;
  programs.fish.enable = true;

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

  # systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  # systemd.timers = {
  #   "reboot-network-off" = {
  #     wantedBy = ["timers.target"];
  #     enable = true;
  #     timerConfig = {
  #       OnBootSec = "10m";
  #       OnUnitActiveSec = "10m";
  #       Unit = "qbittorrent-reschedule.service";
  #     };
  #   }
  # }
  #
  # systemd.services."qbittorrent-reschedule" = {
  #   path = [pkgs.bash pkgs.curl pkgs.jq pkgs.findutils];
  #   enable = true;
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #     ExecStart = "/home/rok/.bin/qbittorrent-reschedule";
  #   };
  #   };

  # systemd.timers = {
  #   # "qbittorrent-reschedule" = {
  #   #   wantedBy = ["timers.target"];
  #   #   enable = false;
  #   #   timerConfig = {
  #   #     OnBootSec = "3m";
  #   #     OnUnitActiveSec = "3m";
  #   #     Unit = "qbittorrent-reschedule.service";
  #   #   };
  #   # };
  #   # "qbittorrent-clean" = {
  #   #   wantedBy = ["timers.target"];
  #   #   enable = true;
  #   #   timerConfig = {
  #   #     OnBootSec = "3m";
  #   #     OnUnitActiveSec = "3m";
  #   #     Unit = "qbittorrent-clean.service";
  #   #   };
  #   # };
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "virtiofs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [
    "nfs"
    "ntfs"
  ];
  services.rpcbind.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # virt-manager
  programs.dconf.enable = true;
  # Enable secure boot and TPM for VMs
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
  virtualisation.spiceUSBRedirection.enable = true;

  # osx-kvm
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  services.spice-vdagentd.enable = true;

  # network
  networking.networkmanager.enable = false;
  networking.useNetworkd = false;
  networking.useDHCP = false;

  # Disable wait online as it's causing trouble at rebuild
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.systemd-udevd.restartIfChanged = false;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  systemd.network.enable = true;
  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 1;
    };
    "20-wireless" = {
      matchConfig.Name = "wlan0";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 2;
    };
  };

  # i18n.inputMethod.type = "kime";
  # i18n.inputMethod.kime.extraConfig = ''
  #   daemon:
  #     modules: [Xim,Indicator]
  #   indicator:
  #     icon_color: White
  #   engine:
  #     hangul:
  #       layout: dubeolsik
  # '';

  # i18n.defaultLocale = "en_US.UTF-8";
  # i18n.inputMethod = {
  #   type = "fcitx5";
  #   enable = true;
  #   fcitx5.addons = with pkgs; [
  #     pkgs.fcitx5-mozc
  #     pkgs.fcitx5-gtk
  #     pkgs.fcitx5-with-addons
  #     pkgs.fcitx5-mozc
  #     # pkgs.unstable.fcitx5-qt
  #     # pkgs.unstable.fcitx5-chinese-addons
  #     pkgs.fcitx5-hangul
  #     # pkgs.unstable.fcitx5-lua
  #   ];
  # };

  # services.xserver.desktopManager.runXdgAutoStartIfNone = true;

  services.upower.enable = true;
  services.fwupd.enable = true;
  # services.qbittorrent.enable = true;
  # services.qbittorrent.port = 4321;

  # security
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
    ];
    packages = with pkgs; [ ];
  };

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     tailscale = pkgs.aca.tailscale;
  #   })
  # ];

  # TODO: should not use this
  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  age.secrets."github.com__aca" = {
    file = ./secrets/github.com__aca.age;
    mode = "777";
  };
  # age.secrets."txxx" = {
  #   file = ./secrets/txxx.age;
  #   mode = "777";
  # };

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

  virtualisation.containers.enable = true;
  virtualisation.containers.policy = {
    default = [ { type = "insecureAcceptAnything"; } ];
    transports = {
      docker-daemon = {
        "" = [ { type = "insecureAcceptAnything"; } ];
      };
    };
  };
  # virtualisation.docker = {
  #   enable = true; # replace with podman
  #   # package = pkgs.docker;
  #   daemon.settings = {
  #     # hosts = ["tcp://127.0.0.1:2375"];
  #     hosts = ["tcp://0.0.0.0:2375"];
  #     # insecure-registries = import ./dev/docker.insecure-registries.nix;
  #   };
  # };

  virtualisation.containers.registries.insecure = [
    "localhost:5000"
    "100.75.184.56:5000"
    "100.85.204.31:5000"
  ];

  # virtualisation.podman = {
  #   enable = false; # replace with podman
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  #   # package = unstable.docker;
  # };

  # programs.firefox.nativeMessagingHosts.tridactyl = true;
  #

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # List packages installed in system profile. To search, run:
  #
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      slack

      (pkgs.google-chrome.override {
        commandLineArgs = [
          # "--ozone-platform-hint=wayland"

          # "--ozone-platform-hint=auto"
          # "--enable-features=UseOzonePlatform"
          # "--ozone-platform-hint=''"
          # "--ozone-platform=''"

          # "--enable-features=WebContentsForceDark"
          "--enable-quic"
          "--enable-zero-copy"
          "--remote-debugging-port=9222"
          # "--force-dark-mode"
          # NOTES: ozone-platform=wayland fcitx win+space not work
          # "--disable-features=UseOzonePlatform"
          # "--gtk-version=4" # fcitx
        ];
      })

      # fluffychat
      # element-desktop
      ntfy-sh
      matrix-commander
      # synapse-admin

      elvish
      glxinfo
      nvme-cli
      xwayland
      neovim-unwrapped
    ]
    ++ [
      # (import ./packages/sublime-merge/default.nix)
      # (import ./packages/hello/hello.nix)
      (import ./pkgs/advcpmv/default.nix)
      # rustdesk
    ]
    ++ [
      # cloud
      awscli2
      # azure-storage-azcopy
      oci-cli
    ]
    ++ [
      # # cloud.k8s
      # kubectl
      # # kubectl-neat
      # # kubectl-tree
      # krew
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
      spice-vdagent
      usbutils
    ]
    ++ [
      # android
      # jdk11
    ]
    ++ [
      # tools
      via
      vial

      convmv # rename filename encoding

      gimp

      # # https://github.com/NixOS/nixpkgs/issues/267579
      # (virt-manager.overrideAttrs (old: {
      #   nativeBuildInputs = old.nativeBuildInputs ++ [ wrapGAppsHook ];
      #   buildInputs = lib.lists.subtractLists [ wrapGAppsHook ] old.buildInputs ++ [
      #     gst_all_1.gst-plugins-base
      #     gst_all_1.gst-plugins-good
      #   ];
      # }))
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
    ]
    ++ [
      # browser

      # https://github.com/fcitx/fcitx5/issues/862
    ]
    ++ [
      # nodePackages_latest.fx
      # nodePackages.yaml-language-server
      # nodePackages.vscode-langservers-extracted

      # formatter
      gofumpt # go
      gotools # go
      gotests
      isort
      shfmt
      taplo
      yamlfmt
      beautysh
      buf
      black
      cmake-format
    ]
    ++ [
      pup
      socat
      sops

      sqlite-interactive
      litecli
      usql
      sqls

      pciutils
      sshfs
      sublime-merge
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
      dig
      inetutils
      wget
      entr
      diskus
      pcmanfm
      zsh
      xsel
      gdb
      _9pfs
      age
      aria2
      atool
      bat
      bolt
      ov
      cron
      delta
      ipset
      dig
      hyperfine
      oauth2-proxy
      scc
      glow
      dog
      nixpkgs-fmt
      desktop-file-utils
      entr
      pandoc
      dura

      # pkgs.unstable.qbittorrent-nox
      # (pkgs.makeDesktopItem {
      #   name = "qbittorrent-nox";
      #   desktopName = "qbittorrent-nox";
      #   exec = "/run/current-system/sw/bin/qbittorrent-nox %u";
      #   mimeTypes = ["x-scheme-handler/magnet" "application/x-bittorrent"];
      #   # icon = "nix-snowflake";
      # })

      # appimage-run
      # qemu
      # act
      libguestfs

      trash-cli
      # webkitgtk
      # git-annex-utils
      gnuplot
      gron
      vbindiff
      nfs-utils
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
      kitty
      # pkgs.unstable.docker-client
      # pkgs.unstable.wezterm
      cmatrix
      # texlive.combined.scheme-full

      sd

      # kdePackages.fcitx5-configtool
      grex
      gperf
      lnav
      lshw
      # pkgs.unstable.ffmpeg_6-full
      ncdu
      netcat-gnu
      nginx
      nnn

      p7zip
      unzip
      ouch

      phodav
      progress

      # (pkgs.writeScriptBin "helloworld" ''
      # #!/usr/bin/env bash
      # notify-send "qbt-torrent-add";
      # ~/bin/qbt torrent add $1;
      # ''
      # )

      waybar
      (luajit.withPackages (
        p: with p; [
          stdlib
        ]
      ))

      nqp
      rakudo

      # tcpdump
      # nmap
      # termshark
      # tshark
      jetbrains.datagrip
      # wireshark

      # terraform
      # tig
      virtiofsd
      # pkgs.unstable.ktorrent
      # pkgs.ktorrent
      # pkgs.rtorrent
      # pkgs.unstable.rutorrent
      watchexec
      wev
      yarn
      zathura
      zef
      patchelf
      ttyd
      powertop
      gptfdisk
      zip

      # video
      # rav1e
      #
      xxHash
      lm_sensors
      zls

      # sway stuff
      xdragon
      alacritty # gpu accelerated terminal
      rofi-wayland
      wayland
      rustc
      cargo
      wdisplays
      xdg-utils
      waypipe
      wl-clipboard # clipboard
      xdg-utils # for opening default programs when clicking links
      dunst
      glib # gsettings
      dracula-theme # gtk theme
      # gnome3.adwaita-icon-theme # default gnome cursors
      pavucontrol
      swayidle
      pulseaudio
      grim # screenshot functionality
      slurp # screenshot functionality
      # bemenu # wayland clone of dmenu
      wdisplays # tool to configure displays
      kanshi

      syncthing
      janet
      mupdf
      pueue
      # helix
      # kakoune
      gh

      # ghostty
      gtk4
      # (pkgs.makeDesktopItem {
      #   name = "ghostty";
      #   desktopName = "ghostty";
      #   exec = "/home/rok/bin/ghostty";
      #   # mimeTypes = [];
      #   # icon = "nix-snowflake";
      # })

      woeusb

      gcc
      gettext
      killall
      git
      fzf
      tmux
      fd
      ripgrep
      vifm
      inetutils
      wget
      # oracle-instantclient
      coreutils-full
      findutils
      moreutils
      glibcLocales
      ghq
      stow
      buildah
      gnumake
      procps
      procs
      fish
      ninja
      meson
      pkg-config
      # jetbrains.datagrip
      # jetbrains.clion
      # (lowPrio uutils-coreutils-noprefix)
      # vscode.fhs
      unrar
      stylua
      # waypipe
      # wl-clipboard
      # xsel
      entr
      diskus
      # kooha
      # obs-studio
      zsh
      # htop
      cmake
      bkt
      nix-tree

      pwgen
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  # tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--advertise-exit-node=false"
  ];

  services.openssh.enable = true;
  # services.syncthing = {
  #   enable = true;
  #   guiAddress = "0.0.0.0:8384";
  #   user = "rok";
  #   dataDir = "/home/rok"; # Default folder for new synced folders
  #   configDir = "/home/rok/.syncthing"; # Folder for Syncthing's settings and keys
  #   settings = {
  #     devices = {
  #       # "root" = {id = "D5HADJL-KDECRCV-GPTJ3RE-MPXNFBH-U6KG3CA-LVSDPP2-MT72ETM-RDM77AG";};
  #       "txxx-nix" = {id = "OBPLELA-TYCW5SL-SNNFVFT-JHKT6WY-RQBDG6L-6RHVNHH-KSTKJQV-ITVQMQF";};
  #       "home" = {id = "JIMRCFS-4AQYUPQ-AGCUPAT-D3GK7EN-WZAMSZM-EPSBDHE-PQFWKT5-4DWUMA3";};
  #     };
  #   };
  # };

  services.syncthing.settings.folders = {
    "txxx" = {
      # Name of folder in Syncthing, also the folder ID
      path = "/home/rok/src/txxx"; # Which folder to add to Syncthing
      devices = [
        "txxx-nix"
        "home"
      ]; # Which devices to share the folder with
    };
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
  #     shares = {
  #       path = "/home/rok/archive/vm/shares";
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
  system.stateVersion = "25.05"; # Did you read the comment?

  # systemd.user.services.pueued = {
  #   path = [ pkgs.pueue ];
  #   enable = false;
  #   serviceConfig.ExecStart = "${pkgs.pueue}/bin/pueued";
  # };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # ubuntu_font_family
      noto-fonts
      # noto-fonts-cjk
      noto-fonts-emoji
      # liberation_ttf
      # fira-code
      # fira-code-symbols
      # mplus-outline-fonts.githubRelease
      # nerdfonts
      # iosevka
      # iosevka-comfy.comfy
      # iosevka-comfy.comfy-duo
      # iosevka-comfy.comfy-fixed
      # iosevka-comfy.comfy-motion
      # dina-font
      # sarasa-gothic

      iosevka
      # (pkgs.nerdfonts.override {fonts = ["IosevkaTermSlab"];})
      nanum
      # proggyfonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        sansSerif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        monospace = [ "Noto Sans Mono" ];
      };
    };
  };

  age.secrets."msmtp.accounts.gmail.password.age" = {
    file = ./secrets/msmtp.accounts.gmail.password.age;
    mode = "777";
  };

  programs.msmtp = {
    enable = true;
    accounts.gmail = {
      host = "smtp.gmail.com";
      from = "aca@gmail.com";
      user = "aca";
      passwordeval = "cat ${config.age.secrets."msmtp.accounts.gmail.password.age".path}";
    };
  };

  # fileSystems."/export/win11" = {
  #   device = "/home/rok/mnt/win11";
  #   options = ["bind"];
  # };
  services.nfs.server.enable = false;
  # services.nfs.server.exports = ''
  #   /export/win11 192.168.0.0/24(rw,nohide,insecure,no_subtree_check) 192.168.122.0/24(rw,nohide,insecure,no_subtree_check)
  # '';

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

    # # Boot Loader
    # loader = {
    #   timeout = 0;
    #   efi.canTouchEfiVariables = true;
    #   systemd-boot.enable = true;
    # };
  };


  systemd.services.rgit = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.git ];
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.rgit}/bin/rgit --db-store /tmp/rgit.db 0.0.0.0:3333 /home/rok/src/git.internal";
      Restart = "on-failure";

      User = "rok";
      Group = "users";

      # CapabilityBoundingSet = "";
      # NoNewPrivileges = true;
      # PrivateDevices = true;
      # PrivateTmp = true;
      # PrivateUsers = true;
      # PrivateMounts = true;
      # ProtectHome = true;
      # ProtectClock = true;
      # ProtectProc = "noaccess";
      # ProcSubset = "pid";
      # ProtectKernelLogs = true;
      # ProtectKernelModules = true;
      # ProtectKernelTunables = true;
      # ProtectControlGroups = true;
      # ProtectHostname = true;
      # RestrictSUIDSGID = true;
      # RestrictRealtime = true;
      # RestrictNamespaces = true;
      # LockPersonality = true;
      # RemoveIPC = true;
      # RestrictAddressFamilies = [
      #   "AF_INET"
      #   "AF_INET6"
      # ];
      # SystemCallFilter = [
      #   "@system-service"
      #   "~@privileged"
      # ];
    };
  };
}
