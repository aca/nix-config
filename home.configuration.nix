# httpr://nixos.org/guides/nix-pills/
{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
} @ args: let
  # inherit (import ./vars.nix) work;
  hostname = "home";
in {
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  # but NIX_PATH is still used by many useful tools, so we set it to the same value as the one used by this flake.
  # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
  # https://github.com/NixOS/nix/issues/9574
  nix.settings.nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";

  # nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.
  # nix.settings.nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
  networking.hostName = hostname;
  networking.extraHosts = (import ./local.nix).networking.extraHosts;

  age.identityPaths = ["/home/rok/.ssh/id_ed25519"];
  age.secrets."txxx".file = ./secrets/txxx.age;
  disabledModules = ["services/networking/tailscale.nix"];

  fileSystems."/mnt/rok-chatreey-t9/cache" = {
    device = "seedbox.local:/mnt/rok-chatreey-t9/cache";
    fsType = "nfs";
    options = ["noatime" "_netdev"];
  };

  fileSystems."/mnt/nas" = {
    device = "192.168.0.16:/volume1/root";
    fsType = "nfs";
    options = ["noatime" "_netdev" ];
  };

  fileSystems."/mnt/archive-0" = {
    device = "192.168.0.24:/mnt/archive-0";
    fsType = "nfs";
    options = ["noatime" "_netdev"];
  };

  # fileSystems."/mnt/archive-0.local/data01" = { device = "192.168.0.24:/mnt/archive-0/data01"; fsType = "nfs"; options = ["noatime"]; };
  # fileSystems."/mnt/archive-0.local/data02" = { device = "192.168.0.24:/mnt/archive-0/data02"; fsType = "nfs"; options = ["noatime"]; };
  # fileSystems."/mnt/archive-0.local/data03" = { device = "192.168.0.24:/mnt/archive-0/data03"; fsType = "nfs"; options = ["noatime"]; };
  # fileSystems."/mnt/archive-0.local/data04" = { device = "192.168.0.24:/mnt/archive-0/data04"; fsType = "nfs"; options = ["noatime"]; };
  # fileSystems."/mnt/archive-0.local/data05" = { device = "192.168.0.24:/mnt/archive-0/data05"; fsType = "nfs"; options = ["noatime"]; };
  # fileSystems."/mnt/archive-0.local/data06" = { device = "192.168.0.24:/mnt/archive-0/data06"; fsType = "nfs"; options = ["noatime"]; };

  # programs.neovim = {
  #   enable = true;
  #   package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  #   configure =  { plugins = [
  #   	pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars
  #   ]; };
  # };
  #

  services.gnome.gnome-keyring.enable = true;

  # services.atuin.enable = true;

  # pkgs.callPackage ./pkgs/scripts.nix { inherit hostName } ;

  # inputs.zapret.options.services.enable = true;

  imports = [
    ./pkgs/tailscale/modules.nix
    # "${inputs.nixpkgs-aca}/nixos/modules/services/networking/tailscale.nix"
    ./pkgs/qbittorrent.nix

    # ./pkgs/scripts.nix
    # (import ./pkgs/scripts.nix {inherit hostname;})
    ./pkgs/scripts.nix
    ./pkgs/tmux.nix

    ./env.nix

    ./pkgs/zapret.nix

    ./pkgs/sway/sway.nix

    # ./pkgs/nix-alien.nix

    ./dev/data.nix
    ./dev/default.nix
    ./dev/go.nix
    ./dev/rust.nix
    ./dev/lua.nix
    ./dev/js.nix
    ./dev/python.nix
    ./dev/nix.nix

    ./pkgs/reboot-if-offline.nix
    ./pkgs/systemd-x.nix
    # ./pkgs/reboot-everyday.nix

    # https://discourse.nixos.org/t/get-qemu-guest-integration-when-running-nixos-rebuild-build-vm/22621
    # "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
    ./hardware/home.nix
    ./pkgs/jkor-matrix.nix
  ];

  services.grafana = {
    enable = false;
    settings.server.http_port = 9000;
    settings.server.http_addr = "127.0.0.1";
  };

  services.prometheus = {
    enable = false;
    port = 9001;
    # scrapeConfigs = [
    #   {
    #     job_name = "oci-xnzm1001-001";
    #     static_configs = [
    #       {
    #         targets = ["100.79.222.108:9100"];
    #       }
    #     ];
    #   }
    # ];
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = ["root" "rok"];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.caddy.enable = true;
  services.caddy.virtualHosts."jkor-matrix.duckdns.org".extraConfig = ''
    reverse_proxy http://archive-0.local:8008
  '';
  services.caddy.virtualHosts."jkor-matrix-ss.duckdns.org".extraConfig = ''
    reverse_proxy http://archive-0.local:8009
  '';

  # systemd.services."ntfy" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       ${pkgs.ntfy-sh}/bin/ntfy serve -c /home/rok/src/root/ntfy/server.yml
  #     '';
  #   };
  # };

  # Doesn't work
  # systemd.services."ntfy" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       ${pkgs.ntfy-sh}/bin/ntfy serve -c /home/rok/src/root/ntfy/server.yml
  #     '';
  #   };
  # };

  # services.ntfy-sh = {
  #   enable = true;
  #   settings = {
  #     base-url = "https://jkor-ntfy.duckdns.org";
  #     listen-http = ":2555";
  #     behind-proxy = true;
  #     auth-default-access = "deny-all";
  #     # auth-file = "/home/rok/src/root/ntfy/user.db";
  #   };
  # };

  # attachment-cache-dir: /var/lib/ntfy-sh/attachments
  # auth-default-access: deny-all
  # auth-file: /var/lib/ntfy-sh/user.db
  # base-url: https://jkor-ntfy.duckdns.org
  # behind-proxy: true
  # cache-file: /var/lib/ntfy-sh/cache-file.db
  # listen-http: :2555

  programs.adb.enable = true;
  programs.fish.enable = true;

  networking.wireless.iwd.enable = true;
  services.udev.packages = with pkgs; [via vial];
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

  # systemd.services."testhome" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       /bin/sh -c "pwd; ls /home/rok/tmp; echo xxx > /home/rok/tmp/xxxxxx; sleep 1000"
  #     '';
  #   };
  # };
  #

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

  # services.cockpit.enable = false;

  # systemd.services."p2p-clipboard" = {
  #   enable = true;
  #   path = [];
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   environment = {
  #     DISPLAY = "/run/user/1000/wayland-1";
  #   };
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "rok";
  #     Restart = "always";
  #     ExecStart = ''
  #       /home/rok/bin/p2p-clipboard --listen 100.85.204.31:34853 --key /home/rok/.config/p2p-clipboard/key
  #     '';
  #   };
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["virtiofs"];

  # NOTES(24/07/07): bluetooth doesn't work, there's issue on 6.9
  # https://discourse.nixos.org/t/bluetooth-controller-issues-with-kernel-6-9/45598/3
  # boot.kernelPackages = pkgs.unstable.linuxPackages_latest; # Linux home 6.9.8 #1-NixOS SMP PREEMPT_DYNAMIC Fri Jul  5 07:38:21 UTC 2024 x86_64 GNU/Linux
  boot.kernelPackages = pkgs.linuxPackages_latest; # Linux home 6.9.8 #1-NixOS SMP PREEMPT_DYNAMIC Fri Jul  5 07:38:21 UTC 2024 x86_64 GNU/Linux
  # boot.kernelPackages = pkgs.unstable.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_latest; # use latest kernel

  boot.supportedFilesystems = ["nfs" "ntfs"];
  services.rpcbind.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # virt-manager
  programs.dconf.enable = true;

  # virtualisation.qemu.guestAgent.enable = true;

  # Enable secure boot and TPM for VMs
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          })
          .fd
        ];
      };
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;

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

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      pkgs.fcitx5-mozc
      pkgs.fcitx5-gtk
      pkgs.fcitx5-with-addons
      pkgs.fcitx5-mozc
      # pkgs.unstable.fcitx5-qt
      # pkgs.unstable.fcitx5-chinese-addons
      pkgs.fcitx5-hangul
      # pkgs.unstable.fcitx5-lua
    ];
  };

  # services.xserver.desktopManager.runXdgAutoStartIfNone = true;

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
    extraGroups = ["networkmanager" "wheel" "docker" "adbusers" "libvirtd" "libvirt" "syncthing" "matrix-synapse"];
    packages = with pkgs; [];
  };

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     tailscale = pkgs.aca.tailscale;
  #   })
  # ];

  # TODO: should not use this
  # age.identityPaths = ["/home/rok/.ssh/id_ed25519"];
  # age.secrets."github.com__aca".file = ./secrets/github.com__aca.age;
  #
  # nixpkgs.overlays = [
  # (import (builtins.fetchTarball {
  #   url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  # }))

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
  #       vifm = pinnedPkgs.vifm;
  #     }
  #   )
  # ];

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
    default = [{type = "insecureAcceptAnything";}];
    transports = {
      docker-daemon = {
        "" = [{type = "insecureAcceptAnything";}];
      };
    };
  };
  virtualisation.docker = {
    enable = true; # replace with podman
    # package = pkgs.docker;
    daemon.settings = {
      # hosts = ["tcp://127.0.0.1:2375"];
      hosts = ["tcp://0.0.0.0:2375"];
      # insecure-registries = import ./dev/docker.insecure-registries.nix;
    };
  };

  virtualisation.containers.registries.insecure = [
    "localhost:5000"
  ];

  # virtualisation.podman = {
  #   enable = false; # replace with podman
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  #   # package = unstable.docker;
  # };

  # programs.firefox.nativeMessagingHosts.tridactyl = true;
  #

  # nixpkgs.config.allowUnfree = true;

  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "vivaldi"
  #   ];

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  # nixpkgs.config.packageOverrides = pkgs: {
  #   # TODO: replace with AMD
  #   # vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  # };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      # TODO: replace with AMD
      # intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      # vaapiVdpau
      # libvdpau-va-gl
    ];
  };

  # List packages installed in system profile. To search, run:
  #
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      neovim
      # fluffychat
      element-desktop
      ntfy-sh
      # pkgs.unstable.matrix-commander
      matrix-commander
      synapse-admin
      elvish
      glxinfo
      nvme-cli
      xwayland
    ]
    ++ [
      nftables
    ]
    ++ [
      # (import ./packages/sublime-merge/default.nix)
      # (import ./packages/hello/hello.nix)
      (import ./pkgs/qbt.nix)

      # (
      #   buildGoModule rec {
      #     name = "qbt";
      #     version = "0.1";
      #     subPackages = "cmd/qbt";
      #     vendorHash = "sha256-PFI5pcwLdE/OBElwV8tm/ganH3/PI6/mCSKn6MKvIgg=";
      #     src = pkgs.fetchFromGitHub {
      #       owner = "aca";
      #       repo = "qbittorrent-cli";
      #       inherit (inputs.qbt-src) rev;
      #       hash = inputs.qbt-src.narHash;
      #     };
      #   }
      # )

      # rustdesk
    ]
    ++ [
      # cloud
      awscli2
      # pkgs.unstable.azure-cli
      # azure-storage-azcopy
      oci-cli
    ]
    ++ [
      # cloud.k8s
      kubectl
      stern
      kubectl-images
      kubectl-node-shell
      kubectl-tree
      kubectx
      kubetail

      dive

      ko
      krew
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
      usbutils

      # pkgs.unstable.ntfy-sh
    ]
    ++ [
      # android
      # android-tools
      # android-studio
      # android-udev-rules
      # flutter
      # jdk11
    ]
    ++ [
      # tools
      via
      vial

      convmv # rename filename encoding

      gimp

      # https://github.com/NixOS/nixpkgs/issues/267579
      # pkgs.unstable.virt-manager
      (virt-manager.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [wrapGAppsHook];
        buildInputs =
          lib.lists.subtractLists [wrapGAppsHook] old.buildInputs
          ++ [
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
          ];
      }))
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice

      # pkgs.unstable.cockpit
    ]
    ++ [
      # browser
      pkgs.microsoft-edge
      # (pkgs.unstable.vivaldi.override {
      #   proprietaryCodecs = true;
      #   enableWidevine = false;
      # })
      # pkgs.unstable.vivaldi-ffmpeg-codecs
      # pkgs.unstable.widevine-cdm
      # chromium
      # pkgs.unstable.vivaldi
      (pkgs.vivaldi.override {
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

      # https://github.com/fcitx/fcitx5/issues/862
      # pkgs.unstable.google-chrome

      # (pkgs.unstable.google-chrome.override {
      #   commandLineArgs = [
      #     # "--ozone-platform-hint=auto"
      #     # "--enable-features=WebContentsForceDark"
      #     # "--ozone-platform-hint=wayland"
      #     # "--enable-quic"
      #     # "--enable-zero-copy"
      #     # "--enable-features=UseOzonePlatform"
      #     # "--remote-debugging-port=9222"
      #     # "--force-dark-mode"
      #     "--gtk-version=4" # fcitx
      #   ];
      # })
    ]
    ++ [
      # nodePackages_latest.fx
      # nodePackages.yaml-language-server
      # nodePackages.vscode-langservers-extracted

      # formatter
      alejandra # nix
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

      sqlite
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
      # direnv
      scc
      glow
      dog
      nixpkgs-fmt
      desktop-file-utils
      entr
      pandoc
      dura

      appimage-run
      # qemu
      act
      libguestfs

      trash-cli
      webkitgtk
      git-annex-utils
      gnuplot
      gron
      vbindiff
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
      kitty
      dive
      cmatrix

      sd

      grex
      gperf
      libreoffice-qt
      lnav
      lshw
      ffmpeg-full
      pkgs.mpv-unwrapped
      ncdu
      # neovim
      netcat-gnu
      nginx
      nnn
      okular

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

      (luajit.withPackages (p:
        with p; [
          stdlib
        ]))

      nqp
      rakudo

      tcpdump
      nmap
      openssl
      termshark
      tshark
      wireshark

      # terraform
      tig
      virtiofsd
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
      # pkgs.unstable.dbus-sway-environment
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
      gnome3.adwaita-icon-theme # default gnome cursors
      swaylock
      pavucontrol
      swayidle
      pulseaudioFull
      grim # screenshot functionality
      slurp # screenshot functionality
      # bemenu # wayland clone of dmenu
      wdisplays # tool to configure displays
      kanshi

      syncthing
      mupdf
      pueue
      helix
      kakoune
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
      # pkgs.unstable.vim
      # pkgs.unstable.jetbrains.idea-community
      ninja
      meson
      pkg-config
      # pkgs.unstable.yazi
      jetbrains.datagrip
      jetbrains.clion
      # (lowPrio uutils-coreutils-noprefix)
      vscode.fhs
      unrar
      stylua
      # waypipe
      # wl-clipboard
      # xsel
      entr
      diskus
      kooha
      obs-studio
      zsh
      # htop
      cmake
      bkt
      nix-tree

      pwgen

      # (callPackage ./pkgs/vtsls.nix {inherit pkgs inputs;})
      # (callPackage ./pkgs/vtsls.nix)

      pdm
      (
        python3.withPackages (ps:
          with ps; [
            requests
            sqlite-utils
            boto3
            pyyaml
            yt-dlp
            pandas
            numpy
          ])
      )
    ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true"];

  services.spice-vdagentd.enable = true;
  # virtualisation.qemu.guestAgent.enable = true;

  services.openssh.enable = true;
  services.syncthing.guiAddress = "0.0.0.0:8384";
  services.syncthing = {
    enable = true;
    user = "rok";
    dataDir = "/home/rok"; # Default folder for new synced folders
    configDir = "/home/rok/.syncthing"; # Folder for Syncthing's settings and keys
    settings = {
      devices = {
        # "root" = {id = "D5HADJL-KDECRCV-GPTJ3RE-MPXNFBH-U6KG3CA-LVSDPP2-MT72ETM-RDM77AG";};
        "rok-txxx-nix" = {id = "OBPLELA-TYCW5SL-SNNFVFT-JHKT6WY-RQBDG6L-6RHVNHH-KSTKJQV-ITVQMQF";};
      };
    };
  };

  services.syncthing.settings.folders = {
    ${(builtins.fromJSON (builtins.readFile config.age.secrets."txxx".path)).workdir} = {
      # Name of folder in Syncthing, also the folder ID
      path = "/home/rok/src/${(builtins.fromJSON (builtins.readFile config.age.secrets."txxx".path)).workdir}"; # Which folder to add to Syncthing
      devices = ["rok-txxx-nix"]; # Which devices to share the folder with
    };
  };

  systemd.extraConfig = ''
    #  DefaultTimeoutStopSec=240s
  '';
  #  ${config.age.secrets."txxx".path}

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 4180;
        to = 4180;
      }
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
      }
      {
        from = 80;
        to = 80;
      }
      {
        from = 443;
        to = 443;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 3702;
        to = 3702;
      } # samba
    ];
    allowPing = true;
  };

  services.samba.openFirewall = true;
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 127.0.0.1 192.168.122. localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      shares = {
        path = "/home/rok/archive/vm/shares";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "rok";
        "force group" = "users";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

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
      noto-fonts-cjk
      noto-fonts-emoji
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
        serif = ["NanumGothic" "Noto Sans Mono"];
        sansSerif = ["NanumGothic" "Noto Sans Mono"];
        monospace = ["Noto Sans Mono"];
      };
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

  # # systemd.services.matrix-synapse.serviceConfig.ProtectHome = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.PrivateUsers = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectSystem = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.RestrictNamespaces = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.NoNewPrivileges = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.PrivateTmp = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectHostname = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.PrivateDevices = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.ReadWritePaths = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RestrictSUIDSGID = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.RestrictSUIDSGID = lib.mkForce "false";
  # # systemd.services.matrix-synapse.serviceConfig.UMask = lib.mkForce "0777";
  # # systemd.services.matrix-synapse.serviceConfig.User = lib.mkForce "root";
  # # systemd.services.matrix-synapse.serviceConfig.Group = lib.mkForce "root";
  #
  # # systemd.services.matrix-synapse.serviceConfig.LockPersonality = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.NoNewPrivileges = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.PrivateDevices = lib.mkForce "";
  # systemd.services.matrix-synapse.serviceConfig.PrivateTmp = lib.mkForce "no";
  # systemd.services.matrix-synapse.serviceConfig.PrivateUsers = lib.mkForce "no";
  # # systemd.services.matrix-synapse.serviceConfig.ProcSubset = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectClock = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectControlGroups = lib.mkForce "";
  # systemd.services.matrix-synapse.serviceConfig.ProtectHome = lib.mkForce "no";
  # systemd.services.matrix-synapse.serviceConfig.ProtectHostname = lib.mkForce "no";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectKernelLogs = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectKernelModules = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectKernelTunables = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectProc = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.ProtectSystem = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.ReadWritePaths = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RemoveIPC = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RestrictAddressFamilies = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RestrictNamespaces = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RestrictRealtime = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RestrictSUIDSGID = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RuntimeDirectoryPreserve = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.RuntimeDirectory = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.SystemCallArchitectures = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.SystemCallFilter = lib.mkForce "";
  # # systemd.services.matrix-synapse.serviceConfig.UMask = lib.mkForce "";
  # users.users.matrix-synapse.createHome = lib.mkForce false;
  services.matrix-synapse.dataDir = "/mnt/matrix-synapse";
}
