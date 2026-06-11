# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}:
let
  containerMachineShell = pkgs.writeShellScript "container-machine-shell" ''
    export PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    exec ${pkgs.bashInteractive}/bin/bash "$@"
  '';

  containerMachineCreateUser = pkgs.writeShellScript "container-machine-create-user" ''
    exit 0
  '';
in
{
  boot.isContainer = true;
  networking.hostName = "tscm";
  # system.stateVersion = lib.mkDefault "26.05";

  # environment.systemPackages = with pkgs; [
  #   bashInteractive
  #   coreutils
  #   gnugrep
  #   nix
  # ];

  users.defaultUserShell = "/etc/machine/shell";
  users.users.root.shell = "/etc/machine/shell";
  # users.mutableUsers = false;
  users.allowNoPasswordLogin = true;

  # Add users here, then access them with:
  #
  #   container machine run -n nixos -u rok -w / id
  #
  # users.users.rok = {
  #   isNormalUser = true;
  #   description = "Rok";
  # };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.bash.interactiveShellInit = ''
    export PATH=/run/wrappers/bin:/run/current-system/sw/bin:$PATH
  '';

  system.activationScripts.containerMachineAppleEntrypointLinks = ''
    ${pkgs.coreutils}/bin/mkdir -p /usr/bin
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/chown /usr/bin/chown
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/cut /usr/bin/cut
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/grep /usr/bin/grep
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/id /usr/bin/id
  '';

  environment.etc."machine/shell" = {
    mode = "0755";
    source = containerMachineShell;
  };

  environment.etc."machine/create-user.sh" = {
    mode = "0755";
    source = containerMachineCreateUser;
  };

  systemd.services.console-getty.enable = false;
  systemd.services.systemd-update-utmp.enable = false;

  services.xserver.enable = true;

  networking.hosts."192.168.195.199" = [
    "home"
    "git.internal"
  ];
  networking.hosts."192.168.195.178" = [ "oci-aca-001" ];

  networking.firewall = {
    enable = true;
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 192.168.195.0/24 -j MASQUERADE
      iptables -A FORWARD -s 192.168.195.0/24 -j ACCEPT
      iptables -A FORWARD -d 192.168.195.0/24 -m state --state RELATED,ESTABLISHED -j ACCEPT
    '';
    allowedTCPPorts = [
      1080
    ];
    allowedUDPPorts = [ 53 ];
  };

  boot.kernelParams = [
    "mitigations=off"
  ];

environment.enableAllTerminfo = true;


  imports = [
    # Include the default lxd configuration.
    # Include the OrbStack-specific configuration.
    ./nixos/fonts.nix
    ./configuration.nix

    ./pkgs/tmux/tmux.nix
    ./pkgs/scripts.nix
    # ./pkgs/i3.nix

    ./env.nix
    # ./hardware/txxx-nix.nix
    # ./nixos/fonts.nix

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
    # ./dev/python.nix
    ./dev/lua.nix
    ./dev/go.nix
    # ./dev/neovim_conf.nix
  ];

  environment.systemPackages = with pkgs; [
    gcc
    typst
    clang
    ethtool
    chromium
    dig
    pnpm
    tcpdump
    python3
    iptables

    bashInteractive
    coreutils
    gnugrep
    nix

    xorg.xauth
    xorg.xinit
    kubectl
    krew

    # sshuttle

    neovim-unwrapped

    wireguard-tools
    ssm-session-manager-plugin
    awscli2
    elvish
    tshark
    termshark
  ];

  environment.sessionVariables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.oracle-instantclient
    ];
    LIBRARY_PATH = "${pkgs.libiconv}/lib";
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

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

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5/DkiXdSA2OJhCq7t931LhBy80G53DWk3/2X0BhI4V rok@minibox"
  ];

  environment.variables.ZK_ROOT = "/home/rok/src/git.internal/zk";
  environment.variables.ZK_LOCAL_ROOT = "/home/rok/src/git.internal/zk/txxx";

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Core C++ runtime (most critical for adb)
    stdenv.cc.cc.lib

    # Compression (adb uses zlib heavily)
    zlib

    # Terminal/console support
    ncurses

    # USB device access
    udev

    # Graphics (emulators, SDK tools)
    libGL
    libGLU

    # Networking/file access
    openssl

    # Common utils
    libuuid
    dbus.lib

    # 32-bit support (if using older SDKs)
    # gcc.cc.lib32 # uncomment if needed
  ];

  security.sudo.wheelNeedsPassword = false;

  # This being `true` leads to a few nasty bugs, change at your own risk!
  users.mutableUsers = false;

  time.timeZone = "Asia/Seoul";

  system.stateVersion = "26.05"; # Did you read the comment?

  services.dnsmasq = {
    enable = true;

    # Forward *everything* to these upstreams

    settings = {
      cache-size = 10000;
      clear-on-reload = true;
      min-cache-ttl = 3600;
      log-queries = true;
      log-dhcp = true;
      server = [
        "8.8.8.8"
      ];
    };
  };

  # virtualisation.docker.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "68bea79acfa612d0"
    ];
  };

  services.dante = {
    enable = true;
    config = ''
      logoutput: syslog
      user.privileged: root
      user.unprivileged: nobody

      # The listening network interface or address.
      internal: 0.0.0.0 port=1080

      # The proxying network interface or address.
      external: eth0

      # socks-rules determine what is proxied through the external interface.
      socksmethod: none

      # client-rules determine who can connect to the internal interface.
      clientmethod: none

      client pass {
          from: 0.0.0.0/0 to: 0.0.0.0/0
      }

      socks pass {
          from: 0.0.0.0/0 to: 0.0.0.0/0
      }
    '';
  };
}
