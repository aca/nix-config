{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./oci-impx-a1.nix
    ./oci.a1.nix
    ./pkgs/qbittorrent.nix

  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  system.stateVersion = "26.05";
  networking.hostName = "oci-impx-a1";

}
