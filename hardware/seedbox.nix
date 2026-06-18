{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];
  boot.loader = {
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };
  fileSystems."/boot/efi" = { device = "/dev/disk/by-uuid/6FE7-219E"; fsType = "vfat"; };
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8dd38305-4975-4277-8f20-0fc8b540c585";
      fsType = "ext4";
    };
}
