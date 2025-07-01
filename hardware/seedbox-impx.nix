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
  # fileSystems."/boot/efi" = {
  #   device = "/dev/disk/by-uuid/6AA5-BC42";
  #   fsType = "vfat";
  # };
  fileSystems."/boot/efi" = { device = "/dev/disk/by-uuid/07BC-6F20"; fsType = "vfat"; };
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
}
