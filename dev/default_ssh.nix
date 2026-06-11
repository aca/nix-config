{
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  nixbuildSSH = ''
    # GSSAPIAuthentication yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    # ForwardAgent yes
    ControlPath /tmp/ssh-control-%r@%h:%p
    ControlPersist yes
    TCPKeepAlive yes
    Compression yes
    ControlMaster auto

    ServerAliveInterval 15
    ServerAliveCountMax 3
    HostKeyAlgorithms +ssh-rsa

    # ssh u00_a408@100.110.230.63 -p 8022
    Host phone 
        User u00_a408
        Hostname 100.110.230.63
        Port 8022
  '';
in
  lib.mkMerge [
    (
      lib.mkIf
      pkgs.stdenv.isLinux (lib.optionalAttrs (options ? programs.ssh.extraConfig) {
        programs.ssh.extraConfig = nixbuildSSH;
      })
    )
    (
      lib.mkIf pkgs.stdenv.isDarwin {
        environment.etc."ssh/ssh_config.d/nixbuild".text = nixbuildSSH;
      }
    )
  ]
