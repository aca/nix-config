# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./pkgs/tailscale/modules.nix
    ./hardware/archive-0.nix
    ./pkgs/server.nix
  ];
  disabledModules = ["services/networking/tailscale.nix"];
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=240s
  '';

  # systemd.services."pueued" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   after = ["network.target"];
  #   serviceConfig = {
  #     Type = "exec";
  #     ExecStart = ''
  #       ${pkgs.pueue}/bin/pueued
  #     '';
  #   };
  # };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true"];

  # https://github.com/amadvance/snapraid/blob/master/snapraid.conf.example

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["virtiofs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  services.smartd.enable = true;
  services.scrutiny.enable = true;
  services.scrutiny.package = pkgs.unstable.scrutiny;
  services.scrutiny.settings.web.influxdb.tls.insecure_skip_verify = true;
  services.scrutiny.collector.enable = true;
  # services.scrutiny.collector.schedule = "*-*-* 05:00:00";
  # services.scrutiny.collector.settings.log.level = "DEBUG";

  services.fwupd.enable = true;
  networking.hostName = "archive-0"; # Define your hostname.
  #  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = false;
  networking.useNetworkd = false;
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks = {
    "10-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 1;
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ko_KR.UTF-8";
    LC_IDENTIFICATION = "ko_KR.UTF-8";
    LC_MEASUREMENT = "ko_KR.UTF-8";
    LC_MONETARY = "ko_KR.UTF-8";
    LC_NAME = "ko_KR.UTF-8";
    LC_NUMERIC = "ko_KR.UTF-8";
    LC_PAPER = "ko_KR.UTF-8";
    LC_TELEPHONE = "ko_KR.UTF-8";
    LC_TIME = "ko_KR.UTF-8";
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # # Configure keymap in X11
  # services.xserver = {
  #   layout = "us";
  #   xkbVariant = "";
  # };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rok = {
    isNormalUser = true;
    description = "rok";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      # firefox
      #  thunderbird
    ];
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  users.users.rok.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    ripgrep
    gptfdisk
    xfsprogs # libxfs.bin # https://github.com/NixOS/nixpkgs/issues/168843
    mergerfs
    smartmontools
    go

    nfs-utils
    wget
    curl
    sqlite-interactive
    pueue
    htop
    vifm
    tmux
    git
    aria2
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # 1: /dev/sda1: UUID="52a12cf6-3521-4159-96a6-3ae260f27e94" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="470a8f90-fb29-46c3-917a-e1c10e6bb6ab"
  # 2: /dev/sdc1: UUID="5b1863da-820f-4d5a-a9dd-6cab33bad173" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="38b3134e-84b2-4739-915d-1a06afb95cc0"
  #
  # 3: /dev/sdd1: UUID="fdb09768-5a3f-4cc2-bb85-aea75a573c2b" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="3477e1bd-141a-4b71-a1ba-7aea9f096cea"
  # 4: /dev/sdc1: UUID="9198ad97-0401-40f5-8d20-9c058a43df59" BLOCK_SIZE="4096" TYPE="ext4" PARTLABEL="Linux filesystem" PARTUUID="390d1c2f-7018-4dd6-ae7c-8a380d140c9e"
  # 5: /dev/sde1: UUID="9bce919f-2958-4e61-a6e1-23fe161f6c66" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="9875c887-506e-44f5-97e6-12eae37cad3e"
  # 6: /dev/sde1: UUID="c15f42e5-b499-4816-83fa-c7d158a91585" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="f6e75704-034b-41e4-8839-d90296c552a0"
  # 7: /dev/sdf1: UUID="cea72b4e-1c58-4559-b239-6dcdc96071ed" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="ca7d108f-52d4-45be-ba8f-fc249089a911"
  # 7: /dev/sdg1: UUID="a97609e7-021e-4ba5-8793-de791a763cb1" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="8da8b846-5d26-4c80-844a-d0b000166d6a"

  fileSystems."/mnt/parity1".device = "/dev/disk/by-uuid/d546a7f7-612e-4b63-84d8-4e751d2fd185";
  fileSystems."/mnt/parity1".fsType = "ext4";
  fileSystems."/mnt/parity1".options = ["users" "nofail"];

  fileSystems."/mnt/parity2".device = "/dev/disk/by-uuid/d1cc9d3e-ff9a-4a40-879c-de5d6e034a22";
  fileSystems."/mnt/parity2".fsType = "ext4";
  fileSystems."/mnt/parity2".options = ["users" "nofail"];

  # fileSystems."/mnt/parity4".device = "/dev/disk/by-uuid/5b1863da-820f-4d5a-a9dd-6cab33bad173";
  # fileSystems."/mnt/parity4".fsType = "xfs";
  # fileSystems."/mnt/parity4".options = ["users" "nofail"];
 
  fileSystems."/mnt/data01".device = "/dev/disk/by-uuid/efe67bd2-1e71-4f96-9806-c45cf0051ebc";
  fileSystems."/mnt/data01".fsType = "ext4";
  fileSystems."/mnt/data01".options = ["users" "nofail"];

  fileSystems."/mnt/data02".device = "/dev/disk/by-uuid/9198ad97-0401-40f5-8d20-9c058a43df59";
  fileSystems."/mnt/data02".fsType = "xfs";
  fileSystems."/mnt/data02".options = ["users" "nofail"];

  fileSystems."/mnt/data03".device = "/dev/disk/by-uuid/22a23836-c847-480d-b8c8-cca7f3258c63";
  fileSystems."/mnt/data03".fsType = "xfs";
  fileSystems."/mnt/data03".options = ["users" "nofail"];

  fileSystems."/mnt/data04".device = "/dev/disk/by-uuid/c15f42e5-b499-4816-83fa-c7d158a91585";
  fileSystems."/mnt/data04".fsType = "xfs";
  fileSystems."/mnt/data04".options = ["users" "nofail"];

  fileSystems."/mnt/data05".device = "/dev/disk/by-uuid/cea72b4e-1c58-4559-b239-6dcdc96071ed";
  fileSystems."/mnt/data05".fsType = "xfs";
  fileSystems."/mnt/data05".options = ["users" "nofail"];

  fileSystems."/mnt/data06".device = "/dev/disk/by-uuid/a2e9f3e1-6c93-4b20-a07b-6b5e9097290c";
  fileSystems."/mnt/data06".fsType = "xfs";
  fileSystems."/mnt/data06".options = ["users" "nofail"];

  services.snapraid = {
    enable = true;
    dataDisks = {
      # to recover, change disk path to other drive and run `snapraid -d d01 -l recovery.log fix`
      d01 = "/mnt/data01";
      d02 = "/mnt/data02";
      d03 = "/mnt/data03";
      d04 = "/mnt/data04";
      d05 = "/mnt/data05";
      d06 = "/mnt/data06";
    };
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/data01/.snapraid.content"
      "/mnt/data02/.snapraid.content"
      "/mnt/data03/.snapraid.content"
      "/mnt/data04/.snapraid.content"
      "/mnt/data05/.snapraid.content"
      "/mnt/data06/.snapraid.content"
    ];
    parityFiles = [
      # replacing snapraid parity disk
      # snapraid fix -d 2-parity # name listed on /etc/snapraid.conf
      "/mnt/parity1/snapraid.parity1,/mnt/parity1/snapraid.parity2"
      "/mnt/parity2/snapraid.parity1,/mnt/parity2/snapraid.parity2"
    ];
    exclude = [
      "*.unrecoverable"
      ".@__thumb/"
      "/tmp/"
      "/lost+found/"

      # macOS
      ".AppleDouble"
      "._AppleDouble"
      ".DS_Store"
      "._.DS_Store"
      ".Thumbs.db"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".AppleDB"
    ];
    sync.interval = "15:00";
    # scrub.interval = "0 0 1 * *";
    # scrub.plan = 8;
  };

  fileSystems."/mnt/archive-0" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/data*";
    options = ["minfreespace=5G" "cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
  };
}
