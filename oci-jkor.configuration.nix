{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware/oci-jkor.nix
    ./oci.a1.nix
    ./pkgs/qbittorrent.nix
    ./pkgs/xpra-chromium.nix
  ];

  system.stateVersion = "25.11";
  networking.hostName = "oci-jkor";
}
