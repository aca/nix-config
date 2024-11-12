{ modulesPath, ... }:
{
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "oci-acadx0-001";
  networking.domain = "subnet09300155.vcn09300155.oraclevcn.com";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home'' ];

  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/8A98-E467"; fsType = "vfat"; };
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/mapper/ocivolume-root"; fsType = "xfs"; };

}

