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

  # Disabled intentionally: this minimal postinstall config starts
  # root-only and expects users to be added declaratively below.
  # Re-enable only if Apple's macOS-matched mutable user setup is
  # needed again.
  containerMachineCreateUser = pkgs.writeShellScript "container-machine-create-user" ''
    export PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    exec /sbin.machine/create-user.sh "$@"
  '';

  # `/sbin/init` entrypoint used after Apple's `/sbin.machine/init`
  # has finished its setup. Recreate `/run/current-system` from the
  # persistent NixOS profile created by `nixos-rebuild switch`, or
  # fall back to the baked image generation on first boot. Then run
  # activation, fix ownership for Apple-mounted `/Users/<name>`
  # directories, and exec systemd as PID 1.
  containerMachineInit = pkgs.writeShellScript "container-machine-init" ''
    set -eu
    export container=container
    export PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/bin:/bin

    system_profile=/nix/var/nix/profiles/system
    default_system_file=/etc/machine/default-system

    if [ -e "$system_profile" ]; then
      current_system="$(${pkgs.coreutils}/bin/readlink -f "$system_profile")"
    elif [ -s "$default_system_file" ]; then
      current_system="$(${pkgs.coreutils}/bin/cat "$default_system_file")"
    else
      echo "container-machine-init: no system profile or default system" >&2
      exit 1
    fi

    ${pkgs.coreutils}/bin/ln -sfn "$current_system" /run/current-system
    "$current_system/activate"

    ${pkgs.gawk}/bin/awk -F: '$3 >= 501 && $3 < 60000 { print $1 ":" $3 ":" $4 }' /etc/passwd |
      while IFS=: read -r name uid gid; do
        if [ -d "/Users/$name" ]; then
          ${pkgs.coreutils}/bin/chown "$uid:$gid" "/Users/$name" 2>/dev/null || true
        fi
      done

    exec ${pkgs.systemd}/lib/systemd/systemd "$@"
  '';

  macCommand = pkgs.writeShellScriptBin "mac" ''
    set -euo pipefail

    host="''${MAC_HOST:-192.168.64.1}"
    port="''${MAC_PORT:-2222}"
    user="kyungrok.chung"

    ssh_args=(
      -p "$port"
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=/dev/null
      -o LogLevel=ERROR
    )

    ssh_cmd=("${pkgs.openssh}/bin/ssh")
    if [ -n "''${MAC_PASSWORD:-}" ]; then
      ssh_cmd=("${pkgs.sshpass}/bin/sshpass" -p "$MAC_PASSWORD" ${pkgs.openssh}/bin/ssh)
    elif ! [ -t 0 ] || ! [ -t 1 ]; then
      ssh_args+=(-o BatchMode=yes)
    fi

    if [ $# -eq 0 ]; then
      if [ -t 0 ] && [ -t 1 ]; then
        exec "''${ssh_cmd[@]}" "''${ssh_args[@]}" -t "$user@$host"
      fi
      exec "''${ssh_cmd[@]}" "''${ssh_args[@]}" "$user@$host"
    fi

    remote_cmd=
    if [ -n "''${PWD:-}" ]; then
      printf -v quoted_pwd '%q' "$PWD"
      remote_cmd="cd $quoted_pwd 2>/dev/null || true; "
    fi

    for arg in "$@"; do
      printf -v quoted_arg '%q' "$arg"
      remote_cmd+=" $quoted_arg"
    done

    exec "''${ssh_cmd[@]}" "''${ssh_args[@]}" "$user@$host" "$remote_cmd"
  '';
in
{
  boot.isContainer = true;
  networking.hostName = "tscm";
  system.stateVersion = "26.05";

  services.dbus.enable = true;

  systemd.services.console-getty.enable = false;
  systemd.services.systemd-update-utmp.enable = false;

  environment.variables."TERM" = "xterm-ghostty";

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;

    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.64.100";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "192.168.64.1";
      interface = "eth0";
    };
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraDaemonFlags = [
    "--encrypt-state=false"
    "--socks5-server=0.0.0.0:1080"
    "-verbose=9"
  ];
  # systemd.services.tailscaled.environment.TS_ENCRYPT_STATE = "false";

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
    export PATH=$PATH:/run/wrappers/bin:/run/current-system/sw/bin
  '';

  system.activationScripts.containerMachineCompatLinks = ''
    # Keep the tiny mutable FHS surface that Apple's early wrapper
    # expects before the NixOS system profile PATH is available.
    #
    # `/sbin/init` must exist across rebuilds because a stopped
    # machine boots through Apple's `/sbin.machine/init`, which then
    # execs `/sbin/init` from the guest rootfs. If this link is
    # missing, the machine cannot boot far enough to repair itself.
    #
    # The `/usr/bin/*` and `/bin/sh` links are deliberately minimal:
    # they cover Apple's bootstrap script and common shebangs, not a
    # full FHS package mirror.
    ${pkgs.coreutils}/bin/mkdir -p /usr/bin /bin /sbin
    ${pkgs.coreutils}/bin/ln -sfn ${containerMachineInit} /sbin/init
    ${pkgs.coreutils}/bin/ln -sfn /sbin/init /init
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/env /usr/bin/env
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/chown /usr/bin/chown
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/cut /usr/bin/cut
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/id /usr/bin/id
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/grep /usr/bin/grep
    ${pkgs.coreutils}/bin/ln -sfn /run/current-system/sw/bin/sh /bin/sh
  '';

  system.activationScripts.containerMachineUserShells = lib.stringAfter [ "etc" "users" "groups" ] ''
    shell=/etc/machine/shell
    tmp=/etc/passwd.container-machine

    ${pkgs.gawk}/bin/awk -F: -v OFS=: -v shell="$shell" '
      $1 == "root" || ($3 >= 501 && $3 < 60000) { $7 = shell }
      { print }
    ' /etc/passwd > "$tmp"

    ${pkgs.coreutils}/bin/mv "$tmp" /etc/passwd
  '';

  environment.etc."machine/shell" = {
    mode = "0755";
    source = containerMachineShell;
  };

  environment.etc."machine/create-user.sh" = {
    mode = "0755";
    source = containerMachineCreateUser;
  };

  services.xserver.enable = true;

  networking.hosts."100.127.31.30" = [
    "git.internal"
  ];

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

    ./pkgs/sway/sway.nix
    ./pkgs/fcitx5.nix

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
    (pkgs.writeShellScriptBin "pbcopy" ''
      ssh mac pbcopy
    '')
    (pkgs.writeShellScriptBin "pbpaste" ''
      ssh mac pbpaste
    '')

    macCommand

    ffmpeg-bin

    waypipe
    gcc
    chromium
    foot
    ghostty
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

    niri
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
      PermitRootLogin = "prohibit-password";
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

  # services.zerotierone = {
  #   enable = true;
  #   joinNetworks = [
  #     "68bea79acfa612d0"
  #   ];
  # };

  systemd.services.mac-forward-auto = {
    path = [ "/run/current-system/sw" ];

    wantedBy = [ "default.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };

    script = ''
      mac-forward-auto
    '';
  };

  # services.dante = {
  #   enable = true;
  #   config = ''
  #     logoutput: syslog
  #     user.privileged: root
  #     user.unprivileged: nobody
  #
  #     # The listening network interface or address.
  #     internal: 0.0.0.0 port=1080
  #
  #     # The proxying network interface or address.
  #     external: eth0
  #
  #     # socks-rules determine what is proxied through the external interface.
  #     socksmethod: none
  #
  #     # client-rules determine who can connect to the internal interface.
  #     clientmethod: none
  #
  #     client pass {
  #         from: 0.0.0.0/0 to: 0.0.0.0/0
  #     }
  #
  #     socks pass {
  #         from: 0.0.0.0/0 to: 0.0.0.0/0
  #     }
  #   '';
  # };
}
