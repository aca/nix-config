{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/tsvm.nix
    ./desktop.linux.nix
    ./workstation.nix
    ./pkgs/tmux/tmux.nix
    ./pkgs/i3.nix

    ./env.nix
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
    ./dev/container.nix
    ./dev/python.nix
    ./dev/lua.nix
    ./dev/go.nix
    ./dev/neovim_conf.nix
  ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraDaemonFlags = [ "--socks5-server=0.0.0.0:1080" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tsvm"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "America/New_York";

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    inetutils
    nebula

    (pkgs.chromium.override {
      commandLineArgs = [
        "--enable-features=WebContentsForceDark"
        "--enable-quic"
        "--enable-zero-copy"
        "--remote-debugging-port=9222"
        "--user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36'"
        # NOTES: ozone-platform=wayland fcitx win+space not work
      ];
    })

    vim
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
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
  system.stateVersion = "25.05"; # Did you read the comment?

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  programs.dconf.enable = true;
  services.tailscale.permitCertUid = "caddy";

  # i18n.inputMethod = {
  #   type = "fcitx5";
  #   enable = true;
  #   fcitx5.addons = with pkgs; [
  #     pkgs.fcitx5-mozc
  #     pkgs.fcitx5-gtk
  #     pkgs.fcitx5-with-addons
  #     pkgs.fcitx5-mozc
  #     pkgs.fcitx5-hangul
  #     pkgs.fcitx5-lua
  #     # pkgs.fcitx5-chinese-addons
  #   ];
  # };

  # age.identityPaths = [ "/home/rok/.ssh/id_ed25519" ];
  # age.secrets.txxx = { file = ./secrets/txxx.age; mode = "777"; };

  # age.secrets."env" = {
  #   file = ./secrets/env.txxx-nix.age;
  #   mode = "777";
  # };
  # environment.extraInit = "source ${config.age.secrets."env".path}";

  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
  ];

  # environment.extraInit = lib.mkAfter ''
  #   export DISPLAY=:0
  # '';

  # Disable wait online as it's causing trouble at rebuild
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.systemd-udevd.restartIfChanged = false;
  # systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
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

  services.nebula.networks.rootnet = {
    enable = true;
    isLighthouse = false;

    settings = {
      lighthouse = {
        hosts = [ "192.168.200.1" ];
      };
    };
    staticHostMap = {
      "192.168.200.1" = [
        "152.67" + 
        # 
        ".199.70:4242"
      ];
    };

    firewall = {
      outbound = [{
        port = "any";
        proto = "any";
        host = "any";
      }];
      inbound = [ 
      {
        port = "any";
        proto = "any";
        host = "any";
      }];
    };

    cert = "/etc/nebula/tsvm.crt"; # The name of this lighthouse is beacon.
    key = "/etc/nebula/tsvm.key";
    ca = "/etc/nebula/ca.crt";
  };
}
