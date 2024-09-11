# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: let
  hostname = "archive-0";
in {
  imports = [
    ./hardware/archive-0.nix
    # ./archive-0.monitoring.nix
    ./archive-0.storage.nix
    ./archive-0.samba.nix
    ./archive-0.nfs.nix

    ./pkgs/scripts.nix
    ./pkgs/jkor-matrix.nix
  ];

  # Hostname
  networking.hostName = "archive-0";

  age.identityPaths = ["/root/.ssh/id_ed25519"];
  # age.secrets."home.services.matrix-sliding-sync.environmentFile".file = ./secrets/home.services.matrix-sliding-sync.environmentFile.age;
  # age.secrets."x".file = ./secrets/xxxxx.age;
  # config.eistration_shared_secret = builtins.readFile config.age.secrets.eistration_shared_secret.path;
  #
  # age.secrets.xxx.file = ./secrets/agenixtest.age;
  # age.secrets.xxx.file = ./secrets/home.services.matrix-synapse.extraConfigFiles.age;

  # SSH keys
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];
  services.openssh.enable = true; # Enable the OpenSSH daemon.

  # Firewall https://nixos.wiki/wiki/Firewall
  networking.firewall.enable = false;

  # Use systemd-networkd instead of networkd, remove all to just use networkd.
  networking.useNetworkd = false;
  networking.useDHCP = false;
  networking.networkmanager.enable = false;
  systemd.network.enable = true;
  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 1;
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  services.tailscale.enable = true; # enable tailscale
  services.fwupd.enable = true; # Hardware update with fwupd

  # scrutiny
  services.smartd.enable = false;
  services.scrutiny.enable = false;
  services.scrutiny.collector.enable = false;
  services.scrutiny.package = pkgs.unstable.scrutiny;
  services.scrutiny.settings.web.influxdb.tls.insecure_skip_verify = true;
  # services.scrutiny.collector.schedule = "*-*-* 05:00:00";
  # services.scrutiny.collector.settings.log.level = "DEBUG";

  boot.kernelPackages = pkgs.linuxPackages_latest; # use latest kernel
  boot.loader.systemd-boot.enable = true; # use systemd-boot instead of grub
  boot.loader.efi.canTouchEfiVariables = true;

  # Internationalisation properties.
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
  time.timeZone = "Asia/Seoul";

  # Packages installed in system profile.
  environment.systemPackages = with pkgs;
    [gptfdisk mergerfs smartmontools nfs-utils lsof]
    ++ [
      vim
      curl
      htop
      tmux
      git
      python3
      hdparm
    ]
    ++ [
      fzf
      neovim
    ];

  # Prevent hang
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=240s
  '';

  # Nix
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
}
