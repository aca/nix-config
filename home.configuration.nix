# httpr://nixos.org/guides/nix-pills/
{
  config,
  pkgs,
  options,
  inputs,
  nix,
  lib,
  ...
}@args:
let
  hostname = "home";
in
# secrets = builtins.extraBuiltins.readSops "/home/rok/.ssh/id_ed25519" ./secrets.json.age;
# secrets = builtins.extraBuiltins.readSops "werwrwer";
# secrets = "wer";
{
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

  services.prometheus.enable = true;

  system.stateVersion = "25.11";

  services.victoriametrics.enable = true;
  services.victoriametrics.extraOptions = [
    "-search.latencyOffset=0s"
  ];

  services.victorialogs.enable = true;
  # curl -N http://oci-aca-001:9428/select/logsql/tail -d 'query=*'
  # curl 'http://oci-aca-001:9428/internal/force_flush'
  services.victorialogs.extraOptions = [
    # "-retention.maxDiskUsagePercent=50"
    "-retentionPeriod=7d"
  ];

  # - The option definition `systemd.extraConfig' in `/nix/store/xa1c3c37j8122smdlj2vrprq9wkj47f6-source/linux.configuration.nix' no longer has any effect; please remove it.
  # Use systemd.settings.Manager instead.
  # systemd.sleep.extraConfig = ''
  #   AllowSuspend=yes
  #   AllowHibernation=yes
  #   AllowHybridSleep=yes
  #   AllowSuspendThenHibernate=yes
  # '';

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    # ensureDatabases = [
    #   "temporal_visibility"
    #   "temporal"
    # ];
    enableTCPIP = true;

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all      all     127.0.0.1/32   trust
      host  all       all     ::1/128        trust
    '';

    settings = {
      # log_connections = true;
      # max_connections = 200;
      shared_preload_libraries = [
        "timescaledb"
        "pg_rational"
      ];
    };

    extensions =
      ps: with ps; [
        postgis
        pg_repack
        timescaledb
        pg_rational
      ];

    ensureUsers = [
      { name = "rok"; }
    ];
    settings.port = 5432;
  };

  programs.mosh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # https://wiki.archlinux.org/title/AMDGPU
  # boot.kernelParams = [ "amdgpu.dcdebugmask=0x10" ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.sway.package = pkgs.unstable.sway;

  # programs.bash.vteIntegration = true;
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      X11DisplayOffset = 10;
      X11UseLocalhost = false;
    };
    extraConfig = ''
      AcceptEnv XDG_RUNTIME_DIR
    '';
  };

  # security.auditd.enable = true;
  # services.journald.audit = true;

  environment.variables.ZK_ROOT = "/home/rok/src/git.internal/zk";

  age.secrets."hosts" = {
    file = ./secrets/hosts.age;
    mode = "777";
  };

  system.activationScripts."update-hosts" = ''
    cat /etc/hosts > /etc/hosts.bak
    rm /etc/hosts
    cat /etc/hosts.bak "${config.age.secrets."hosts".path}" >> /etc/hosts
  '';

  # networking.hosts = {
  #   "127.0.0.1" = [
  #     "localhost.internal"
  #     "home.internal"
  #   ];
  # };

  age.secrets.env = {
    file = ./secrets/home/env.age;
    mode = "444";
  };

  # environment.extraInit = ''
  #   set -o allexport
  #   if [ -f "${config.age.secrets.env.path}" ]; then
  #     source "${config.age.secrets.env.path}"
  #   fi
  #   set +o allexport
  # '';

  programs.nbd.enable = false;
  services.zerotierone.enable = true;

  # networking.nameservers = [  "1.1.1.1" ];
  # # Enable Adguard Home and set bassic settigns
  # networking.nameservers = [ "127.0.0.1" ];
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

  # services.resolved = {
  #   enable = true;
  #   # dnssec = "false";
  #   # domains = ["~."];
  #   # fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
  #   # extraConfig = ''
  #   #   DNSOverTLS=yes
  #   # '';
  #   # extraConfig = ''
  #   #   DNSOverTLS=false
  #   # '';
  # };

  # services.netbird.enable = true;

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
  # networking.extraHosts = (import ./local.nix).networking.extraHosts;

  age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  # age.secrets."github.com__aca" = {
  #   file = ./secrets/github.com__aca.age;
  #   mode = "777";
  # };
  # age.secrets.txxx = { file = ./secrets/txxx.age; path = "/etc/txxx"; mode = "777"; };
  # age.secrets."github.com__aca".file = ./secrets/github.com__aca.age;

  fileSystems."/mnt/archive-0" = {
    device = "192.168.0.242:/mnt/archive-0";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      "x-systemd.requires=network-online.target"
    ];
  };

  # pkgs.callPackage ./pkgs/scripts.nix { inherit hostName } ;

  disabledModules = [
    # "services/networking/cgit.nix"
    # "services/networking/syncthing.nix"
  ];

  imports = [
    # "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/syncthing.nix"

    ./pkgs/fcitx5.nix
    ./dev/netshoot.nix
    ./home.network.nix
    ./home.grafana.nix

    # ./dev/android.nix

    ./home.timers.nix
    ./pkgs/zerotierone.nix
    ./git.internal.nix
    ./linux.configuration.nix

    ./configuration.nix
    ./linux.desktop.nix

    ./pkgs/wine.nix
    ./dev/neovim_conf.nix
    ./dev/git.nix
    ./pkgs/virt.nix
    ./workstation.nix
    ./networking.nix

    ./pkgs/scripts.nix
    ./pkgs/video.nix
    # ./pkgs/qBittorrent.nix
    ./pkgs/zapret.nix

    ./pkgs/sway/sway.nix

    ./pkgs/nix-alien.nix

    ./dev/data.nix
    ./dev/java.nix
    ./dev/default.nix
    ./dev/go.nix
    ./dev/c.nix
    ./dev/container.nix
    ./dev/zig.nix
    ./dev/rust.nix
    ./dev/lua.nix
    ./dev/js.nix
    ./dev/python.nix
    ./dev/nix.nix

    ./pkgs/reboot-if-offline.nix
    # ./pkgs/systemd-x.nix
    # ./pkgs/reboot-everyday.nix

    ./hardware/home.nix
    # ./pkgs/jkor-matrix.nix
  ];

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

  programs.adb.enable = true;
  # programs.fish.enable = true;

  services.udev.packages = with pkgs; [
    qmk
    qmk-udev-rules # the only relevant
    qmk_hid
    via
    vial
    # android-udev-rules
  ];

  # https://get.vial.today/manual/linux-udev.html#device-specific-udev-rules
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e4d1", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  # NOTES: When public wifi doesn't work, comment all dns config and use default dns configuration on network
  # networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

  # systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # systemd.services."bluetooth-keyboard" = {
  #   enable = true;
  #   path = [ ];
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   environment = {
  #     WAYLAND_DISPLAY = "wayland-1";
  #     XDG_RUNTIME_DIR = "/run/user/1000";
  #   };
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "rok";
  #     Restart = "always";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/swayidle timeout 30 "" resume "/run/current-system/sw/bin/bluetoothctl connect 6C:93:08:65:FF:E4"
  #     '';
  #   };
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "virtiofs" ];

  # NOTES(24/07/07): bluetooth doesn't work, there's issue on 6.9
  # https://discourse.nixos.org/t/bluetooth-controller-issues-with-kernel-6-9/45598/3
  # boot.kernelPackages = pkgs.linuxPackages_testing;
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_latest; # use latest kernel

  boot.supportedFilesystems = [
    "nfs"
    "ntfs"
  ];
  services.rpcbind.enable = true;

  # virt-manager
  programs.dconf.enable = true;

  # virtualisation.qemu.guestAgent.enable = true;

  # Enable secure boot and TPM for VMs

  # network

  # i18n.inputMethod = {
  #   type = "kime";
  #   # enable = true;
  #   # fcitx5.addons = with pkgs; [
  #   #   pkgs.fcitx5-mozc
  #   #   pkgs.fcitx5-gtk
  #   #   pkgs.fcitx5-with-addons
  #   #   pkgs.fcitx5-mozc
  #   #   # pkgs.unstable.fcitx5-qt
  #   #   # pkgs.unstable.fcitx5-chinese-addons
  #   #   pkgs.fcitx5-hangul
  #   #   # pkgs.unstable.fcitx5-lua
  #   # ];
  # };

  # services.xserver.desktopManager.runXdgAutoStartIfNone = true;

  services.upower.enable = true;
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
    homeMode = "777";
    description = "rok";
    packages = with pkgs; [
      inputs.kata.packages.${system}.default
    ];
    extraGroups = [
      "networkmanager"
      "kvm"
      "video"
      "render"
      "wheel"
      "docker"
      "libvirtd"
      "libvirt"
      "syncthing"
      "matrix-synapse"
      "adbusers"
      "cgit"
    ];
  };

  # https://www.youtube.com/watch?v=3WrprUS1eUQ
  environment.variables = {
    ANDROID_HOME = "$HOME/.android/sdk";
    ANDROID_SDK_ROOT = "$HOME/.android/sdk";
    JAVA_HOME = "${pkgs.jdk17}"; # <-- Point to the Nix-provided JDK
  };

  # TODO: should not use this
  # age.identityPaths = ["/home/rok/.ssh/id_ed25519"];
  # age.secrets."github.com__aca".file = ./secrets/github.com__aca.age;

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

  virtualisation.docker = {
    enable = true; # replace with podman
    # package = pkgs.docker;
    daemon.settings = {
      # hosts = ["tcp://127.0.0.1:2375"];
      # hosts = ["tcp://0.0.0.0:2375"];
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

  # nixpkgs.config.permittedInsecurePackages = [
  #   "olm-3.2.16"
  # ];

  services.ollama.enable = true;

  # programs.firefox.nativeMessagingHosts.tridactyl = true;
  #

  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "vivaldi"
  #   ];

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  # nixpkgs.config.packageOverrides = pkgs: {
  #   # TODO: replace with AMD
  #   # vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  # };

  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     # TODO: replace with AMD
  #     # intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #     # vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #     # vaapiVdpau
  #     # libvdpau-va-gl
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  #
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      tigerbeetle
      claude-desktop
      emacs
      nasm
      nasmfmt

      scrcpy
      kicad
      abduco
      qrencode
      wireguard-tools

      feh

      ethtool

      remmina
      vial
      whisper-cpp
      visidata
      wlx-overlay-s
      # minio
      versitygw
      omnissa-horizon-client

      feh

      remmina
      nebula
      go-audit
      openbao
      mkcert
      # neovim
      # fluffychat
      element-desktop
      ntfy-sh
      # neovide
      # pkgs.unstable.matrix-commander
      typst
      matrix-commander
      synapse-admin
      elvish
      nvme-cli
      xc
      xwayland
      fcp
    ]
    ++ [
      nftables

      # vmware-horizon-client
      xpra
      jmtpfs
    ]
    ++ [
      # (import ./packages/sublime-merge/default.nix)
      # (import ./packages/hello/hello.nix)
      (pkgs.callPackage ./pkgs/qbt.nix { })

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
      python3
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
      android-studio
      jdk17
      # android-udev-rules
      # flutter
      # jdk11
      tig
      lazygit
    ]
    ++ [
      litecli
      # tools
      via
      vial

      convmv # rename filename encoding

      gimp

      # https://github.com/NixOS/nixpkgs/issues/267579
      # pkgs.unstable.virt-manager
      (virt-manager.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ wrapGAppsHook3 ];
        buildInputs = lib.lists.subtractLists [ wrapGAppsHook3 ] old.buildInputs ++ [
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
        ];
      }))
      virt-viewer
      janet
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice

      # pkgs.unstable.cockpit
    ]
    ++ [
      # browser
      # (pkgs.unstable.microsoft-edge.override {
      #   commandLineArgs = [
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9227"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #   ];
      # })
      # (pkgs.unstable.vivaldi.override {
      #   proprietaryCodecs = true;
      #   enableWidevine = false;
      # })
      # pkgs.unstable.vivaldi-ffmpeg-codecs
      # pkgs.unstable.widevine-cdm
      # (pkgs.unstable.vivaldi.override {
      #   # mesa = pkgs.mesa;
      #   commandLineArgs = [
      #     # "--ozone-platform-hint=wayland"
      #
      #     # "--ozone-platform-hint=auto"
      #     # "--enable-features=UseOzonePlatform"
      #     # "--ozone-platform-hint=''"
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

      # chromium
      (chromium.override {
        commandLineArgs = [
          # "--enable-features=WebContentsForceDark"
          # "--enable-quic"
          # "--enable-zero-copy"
          "--enable-quic"
          "--enable-zero-copy"
          "--disable-features=DarkMode"
          "--ozone-platform=x11"
          "--remote-debugging-port=9224"
          # "--user-data-dir=/home/rok/store/chromium/main"
          # NOTES: ozone-platform=wayland fcitx win+space not work
        ];
      })

      (google-chrome.override {
        # (pkgs.google-chrome.override {
        commandLineArgs = [
          # "--enable-features=WebContentsForceDark"
          "--enable-quic"
          "--enable-zero-copy"
          "--disable-features=DarkMode"
          "--ozone-platform=x11"
          "--remote-debugging-port=9222"
          "--user-data-dir=/home/rok/store/chrome/main"
          # NOTES: ozone-platform=wayland fcitx win+space not work
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
      # libguestfs
      # libguestfs-with-appliance # https://github.com/NixOS/nixpkgs/issues/37540
      # guestfs-tools
      exfat
      # formatter
      alejandra # nix
      gofumpt # go
      gotools # go
      gotests
      isort
      shfmt
      taplo
      vscode-fhs
      yamlfmt
      beautysh
      buf

      flatbuffers
      black
      cmake-format
    ]
    ++ [
      pup
      socat
      sops

      sqlite-interactive
      redis
      litecli
      usql
      sqls

      pciutils
      sshfs
      browsh
      firefox-bin
      sublime-merge
      # git-cola
      sshpass
      telegram-desktop
      libnotify
      lsof
      inkscape
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
      sshuttle
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
      scc
      glow
      dog
      nixpkgs-fmt
      desktop-file-utils
      entr
      pandoc
      # davinci-resolve
      dura
      valgrind

      # appimage-run
      # qemu
      # act

      openai-whisper

      trash-cli
      xclip
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
      dive
      cmatrix

      sd

      grex
      gperf
      libreoffice-qt
      lnav
      lshw
      ncdu
      # neovim
      netcat-gnu
      nginx
      nnn
      # okular
      jetbrains.datagrip

      p7zip
      unzip
      ouch

      phodav
      progress

      clickhouse

      neovim-unwrapped
      scrot
      # mitmproxy
      hey
      (luajit.withPackages (
        p: with p; [
          stdlib
        ]
      ))

      wirelesstools

      # terraform
      tig
      virtiofsd
      watchexec
      wev
      yarn
      zathura
      obsidian
      zef
      patchelf
      ttyd
      powertop
      gptfdisk
      zip

      # rav1e
      #
      xxHash
      lm_sensors
      zls

      (pulumi.withPackages (
        p: with p; [
          pulumi-go
          pulumi-nodejs
        ]
      ))

      dunst

      tree-sitter

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
      #
      nushell

      rclone
      pinta
      woeusb

      gcc
      wimlib
      gettext
      killall
      git
      fzf
      tmux
      fd
      ripgrep
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
      fluent-bit

      libpq
      tyson

      procs
      fish
      # pkgs.unstable.vim
      # pkgs.unstable.jetbrains.idea-community
      ninja
      meson
      pkg-config
      libllvm
      appimage-run
      # pkgs.unstable.yazi
      # neovide
      # jetbrains.clion
      # emacs
      # (lowPrio uutils-coreutils-noprefix)
      vscode.fhs
      detox
      unrar
      stylua
      # waypipe
      # wl-clipboard
      # xsel
      entr
      diskus
      nq
      kooha
      vector
      obs-studio
      zsh
      # htop
      nautilus
      cmake
      bkt

      amdgpu_top
      pwgen

      ffmpeg-full
      quartoMinimal

      # (quarto.override {
      #   python3 = pkgs.python3;
      #   extraPythonPackages =
      #     ps: with ps; [
      #       numpy
      #       jupyter
      #       pandas
      #       psycopg2
      #       plotly
      #       pyyaml
      #       jupyter
      #     ];
      # })
    ];

  services.tailscale.enable = true;
  # services.tailscale.useRoutingFeatures = "both";
  # services.tailscale.extraSetFlags = [
  #   "--ssh"
  #   # "--advertise-exit-node=true"
  # ];
  # services.tailscale.extraUpFlags = [ "--accept-routes" ]; # pull whatever routes you approve
  # services.tailscale.extraDaemonFlags = [ "--tun=userspace-networking" "--socks5-server=localhost:1080" "--outbound-http-proxy-listen=localhost:1080"];
  # services.tailscale.extraDaemonFlags = ["--socks5-server=0.0.0.0:1080"];

  services.spice-vdagentd.enable = true;
  # virtualisation.qemu.guestAgent.enable = true;

  # services.syncthing = {
  #   enable = false;
  #   guiAddress = "0.0.0.0:8384";
  #   user = "rok";
  #   dataDir = "/home/rok"; # Default folder for new synced folders
  #   configDir = "/home/rok/.syncthing"; # Folder for Syncthing's settings and keys
  #   settings = {
  #     #   devices = {
  #     #     # "home" = {id = "JIMRCFS-4AQYUPQ-AGCUPAT-D3GK7EN-WZAMSZM-EPSBDHE-PQFWKT5-4DWUMA3";};
  #     #     "root" = {
  #     #       id = "D5HADJL-KDECRCV-GPTJ3RE-MPXNFBH-U6KG3CA-LVSDPP2-MT72ETM-RDM77AG";
  #     #     };
  #     #     "txxx-nix" = {
  #     #       id = "OBPLELA-TYCW5SL-SNNFVFT-JHKT6WY-RQBDG6L-6RHVNHH-KSTKJQV-ITVQMQF";
  #     #     };
  #     #     "txxx" = {
  #     #       id = "BMTXVFR-DXR7XUT-TQSN65G-4SPN2SE-Z35J44T-7A4HJEE-6LRI2XT-ZHZS5QF";
  #     #     };
  #     #   };
  #   };
  # };

  # services.syncthing.settings.folders = {
  #   "txxx" = {
  #     # Name of folder in Syncthing, also the folder ID
  #     path = "/home/rok/src/txxx"; # Which folder to add to Syncthing
  #     devices = [
  #       "txxx-nix"
  #       "root"
  #       "txxx"
  #     ]; # Which devices to share the folder with
  #   };
  # };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 4180;
        to = 4180;
      }

      {
        from = 29344;
        to = 29344;
      } # wg0

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
      {
        from = 1080;
        to = 1080;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 3702;
        to = 3702;
      } # samba
      {
        from = 40000;
        to = 40000;
      } # samba
      {
        from = 29344;
        to = 29344;
      } # wg0
    ];
    allowPing = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # ubuntu_font_family
      noto-fonts
      # noto-fonts-cjk
      # comin
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
          "NanumGothic"
          "Noto Sans Mono"
        ];
        sansSerif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        monospace = [
          "NanumGothicCoding"
          "Noto Sans Mono"
        ];
      };
    };
  };

  # services.davfs2.enable = true;

  services.nfs.server.enable = false;
  # services.gvfs.enable = true;

  # fileSystems."/mnt/seedbox-impx" = {
  #   device = "192.168.0.242:/mnt/seedbox-impx";
  #   fsType = "nfs";
  #   # "x-systemd.device-timeout=10s"
  #   # x-systemd.automount
  #   # _netdev
  #   options = [
  #     "noatime"
  #     # "x-systemd.requires=network-online.target"
  #   ];
  # };

  # fileSystems."/mnt/seedbox" = {
  #   device = "192.168.0.242:/mnt/seedbox";
  #   fsType = "nfs";
  #   # "x-systemd.device-timeout=10s"
  #   # x-systemd.automount
  #   # _netdev
  #   options = [
  #     "noatime"
  #     # "x-systemd.requires=network-online.target"
  #   ];
  # };

  # fileSystems."/mnt/tmp" = {
  #   device = "192.168.0.242:/mnt/tmp";
  #   fsType = "nfs";
  #   # "x-systemd.device-timeout=10s"
  #   # x-systemd.automount
  #   # _netdev
  #   options = [
  #     "noatime"
  #     # "x-systemd.requires=network-online.target"
  #   ];
  # };

  # fileSystems."/mnt/data10" = {
  #   device = "192.168.0.242:/mnt/data10";
  #   fsType = "nfs";
  #   # "x-systemd.device-timeout=10s"
  #   # x-systemd.automount
  #   # _netdev
  #   options = [
  #     "noatime"
  #     # "x-systemd.requires=network-online.target"
  #   ];
  # };

  fileSystems."/mnt/tmp" = {
    device = "192.168.0.242:/mnt/tmp";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      # "x-systemd.requires=network-online.target"
    ];
  };

  fileSystems."/mnt/tor" = {
    device = "192.168.0.242:/mnt/tor";
    fsType = "nfs";
    # "x-systemd.device-timeout=10s"
    # x-systemd.automount
    # _netdev
    options = [
      "noatime"
      # "x-systemd.requires=network-online.target"
    ];
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # services.vector.journaldAccess = true;
  # services.vector.enable = true;
  # services.vector.settings = builtins.fromTOML (builtins.readFile ./vector.systemd.toml);

  boot.kernelParams = [
    "mitigations=off"
  ];

  # systemd.services."testservice" = {
  #   enable = true;
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     ProtectHome = "false";
  #     ProtectSystem = "false";
  #     PrivateUsers = "false";
  #     ReadWritePaths = "/home/rok";
  #     PrivateTmp = "false";
  #     Type = "exec";
  #     ExecStart = ''
  #       /run/current-system/sw/bin/sqlite3 /home/rok/asset.db '.schema'
  #       /run/current-system/sw/bin/sleep 10000
  #     '';
  #   };
  # };
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

  systemd.services."log-test" = {
    serviceConfig.User = "rok";
    serviceConfig.EnvironmentFile = "/run/agenix/env";
    serviceConfig.Environment = [ "LOG_FORMAT=json" ];
    serviceConfig.ExecSearchPath = "/run/current-system/sw/bin";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "5s";
    serviceConfig.WorkingDirectory = "/home/rok/src/git.internal/bot";
    path = [ "/run/current-system/sw" ];
    script = "go run ./cmd/log-test";
  };
}
