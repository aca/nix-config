# { modulesPath, ... }:
# {
#   imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
#   boot.loader.grub = {
#     efiSupport = true;
#     efiInstallAsRemovable = true;
#     device = "nodev";
#     configurationLimit = 2;
#   };
#   fileSystems."/boot" = { device = "/dev/disk/by-uuid/6305-5783"; fsType = "vfat"; };
#   boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
#   boot.initrd.kernelModules = [ "nvme" ];
#   fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
# }
#
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5fef6656-c8f1-40d8-b27a-e5e7dbd415d6";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6305-5783";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s6.useDHCP = lib.mkDefault true;
  # networking.interfaces.tailscale0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}

