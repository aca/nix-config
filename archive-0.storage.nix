{
  config,
  pkgs,
  lib,
  ...
}: {
  # disk
  fileSystems."/mnt/parity1".device = "/dev/disk/by-uuid/d546a7f7-612e-4b63-84d8-4e751d2fd185";
  fileSystems."/mnt/parity1".fsType = "ext4";
  fileSystems."/mnt/parity1".options = ["users" "nofail"];

  fileSystems."/mnt/parity2".device = "/dev/disk/by-uuid/d1cc9d3e-ff9a-4a40-879c-de5d6e034a22";
  fileSystems."/mnt/parity2".fsType = "ext4";
  fileSystems."/mnt/parity2".options = ["users" "nofail"];

  fileSystems."/mnt/data01".device = "/dev/disk/by-uuid/efe67bd2-1e71-4f96-9806-c45cf0051ebc";
  fileSystems."/mnt/data01".fsType = "ext4";
  fileSystems."/mnt/data01".options = ["users" "nofail"];

  fileSystems."/mnt/data02".device = "/dev/disk/by-uuid/81ff49c6-2cb3-44fc-a47d-2e76b1804f64";
  fileSystems."/mnt/data02".fsType = "ext4";
  fileSystems."/mnt/data02".options = ["users" "nofail"];

  fileSystems."/mnt/data03".device = "/dev/disk/by-uuid/f11105b8-85b4-46fa-8b1c-49450493e2c7";
  fileSystems."/mnt/data03".fsType = "ext4";
  fileSystems."/mnt/data03".options = ["users" "nofail"];

  fileSystems."/mnt/data04".device = "/dev/disk/by-uuid/e625ce8a-7a4e-4f17-9b89-4f9367e17377";
  fileSystems."/mnt/data04".fsType = "ext4";
  fileSystems."/mnt/data04".options = ["users" "nofail"];

  fileSystems."/mnt/data05".device = "/dev/disk/by-uuid/cea72b4e-1c58-4559-b239-6dcdc96071ed";
  fileSystems."/mnt/data05".fsType = "xfs";
  fileSystems."/mnt/data05".options = ["users" "nofail"];

  fileSystems."/mnt/data06".device = "/dev/disk/by-uuid/a2e9f3e1-6c93-4b20-a07b-6b5e9097290c";
  fileSystems."/mnt/data06".fsType = "xfs";
  fileSystems."/mnt/data06".options = ["users" "nofail"];

  # snapraid
  # https://github.com/amadvance/snapraid/blob/master/snapraid.conf.example
  services.snapraid = {
    enable = true;
    dataDisks = {
      d01 = "/mnt/data01";
      d02 = "/mnt/data02";
      d03 = "/mnt/data03";
      d04 = "/mnt/data04";
      d05 = "/mnt/data05";
      d06 = "/mnt/data06";
    };
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/data01/.snapraid.content"
      "/mnt/data02/.snapraid.content"
      "/mnt/data03/.snapraid.content"
      "/mnt/data04/.snapraid.content"
      "/mnt/data05/.snapraid.content"
      "/mnt/data06/.snapraid.content"
    ];
    parityFiles = [
      # define 2 parity disk, as ext4 has 16TB file size limit, split parity file for each disk.
      "/mnt/parity1/snapraid.parity1,/mnt/parity1/snapraid.parity2"
      "/mnt/parity2/snapraid.parity1,/mnt/parity2/snapraid.parity2"
    ];
    exclude = [
      "*.unrecoverable"
      ".@__thumb/"
      "/tmp/"
      "/lost+found/"

      # macOS
      ".AppleDouble"
      "._AppleDouble"
      ".DS_Store"
      "._.DS_Store"
      ".Thumbs.db"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".AppleDB"
    ];
    sync.interval = "06:00"; # sync daily
    scrub.interval = "*-*-1,11,21 02:00:00"; # scrub every 10 days
    # scrub.plan = 8;
  };

  # mergerfs
  fileSystems."/mnt/archive-0" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/data*";
    options = ["minfreespace=5G" "cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
  };

  # hack to fix permission issue
  system.activationScripts.fix-perm.text = ''
    chmod 777 /mnt/data01
    chmod 777 /mnt/data02
    chmod 777 /mnt/data03
    chmod 777 /mnt/data04
    chmod 777 /mnt/data05
    chmod 777 /mnt/data06
    chmod 777 /mnt/archive-0
  '';
}
