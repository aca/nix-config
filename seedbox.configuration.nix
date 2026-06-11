{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware/seedbox.nix
    ./oci.a1.nix
    ./pkgs/qbittorrent.nix

  ];

  system.stateVersion = "25.11";
  networking.hostName = "seedbox";

}
