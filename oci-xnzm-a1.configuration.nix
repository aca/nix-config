{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./oci-xnzm-a1.nix
    ./oci.a1.nix
    ./pkgs/qbittorrent.nix
    ./oci-xnzm-a1.app.nix

  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # age.secrets."env" = {
  #   file = ./secrets/oci-aca-001/env.age;
  #   mode = "444";
  # };
  # environment.extraInit = "source ${config.age.secrets."env".path}";

  system.stateVersion = "26.05";
  networking.hostName = "oci-xnzm-a1";

  virtualisation.oci-containers = {
    backend = "podman"; # or "docker"
    containers.oci-xnzm-a1 = {
      image = "ghcr.io/aca/containers/postgres-18:latest-arm64";
      ports = [ "5432:5432" ];
      volumes = [ "/var/lib/postgresql/oci-xnzm-a1:/var/lib/postgresql/data" ]; # disk mount
    };
  };

  # Open the firewall if external clients need to connect (private network only)
  # networking.firewall.allowedTCPPorts = [ 5432 ];


  # required for DNAT to 127.0.0.1 from external interfaces. Without this, the kernel silently drops packets routed to loopback from non-loopback interfaces.
  boot.kernel.sysctl."net.ipv4.conf.all.route_localnet" = 1;

  networking.firewall = {
    enable = true;
    logRefusedConnections = true;
    trustedInterfaces = [ "zt+" ];   # zt로 시작하는 모든 인터페이스 신뢰
    allowedTCPPorts = [
      22
      80
      443
    ];

    # chrome remote debugging, tailscale 127.0.0.2 -> 127.0.0.1:9222
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp ! -s 127.0.0.0/8 --dport 9222 -j DNAT --to-destination 127.0.0.1:9222
      iptables -t nat -A OUTPUT -p tcp -d 127.0.0.2 --dport 9222 -j DNAT --to-destination 127.0.0.1:9222
    '';
    # allowedUDPPorts = [
    #   22
    #   80
    #   443
    # ];
  };

  # services.zerotierone.enable = true;

  # services.zerotierone = {
  #   joinNetworks = [
  #     "68bea79acfa612d0"
  #   ];
  # };
  #


}
