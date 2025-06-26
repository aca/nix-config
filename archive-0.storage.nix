{
  config,
  pkgs,
  lib,
  ...
}:
{
  # disk
  # fileSystems."/mnt/parity1".device = "/dev/disk/by-uuid/d546a7f7-612e-4b63-84d8-4e751d2fd185";
  # fileSystems."/mnt/parity1".fsType = "ext4";
  # fileSystems."/mnt/parity1".options = ["users" "nofail"];

  fileSystems."/mnt/parity1".device = "/dev/disk/by-uuid/58d76479-d3ce-435c-b21c-df0820432b06";
  fileSystems."/mnt/parity1".fsType = "ext4";
  fileSystems."/mnt/parity1".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/parity2".device = "/dev/disk/by-uuid/da201609-a9b2-46e6-9911-e23fd5eda6a5"; # parity 2
  fileSystems."/mnt/parity2".fsType = "ext4";
  fileSystems."/mnt/parity2".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data01".device = "/dev/disk/by-uuid/38e2e623-e071-4ffa-9c74-242f46a39e70";
  fileSystems."/mnt/data01".fsType = "ext4";
  fileSystems."/mnt/data01".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data02".device = "/dev/disk/by-uuid/bb51b131-eb4f-4c71-86b9-b9a908033424";
  fileSystems."/mnt/data02".fsType = "ext4";
  fileSystems."/mnt/data02".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data03".device = "/dev/disk/by-uuid/7a9e26f7-9fe0-405e-aa1d-ccdc581ef072";
  fileSystems."/mnt/data03".fsType = "ext4";
  fileSystems."/mnt/data03".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data04".device = "/dev/disk/by-uuid/c011fd3e-f4e3-4460-96b6-eed9b5c17303";
  fileSystems."/mnt/data04".fsType = "ext4";
  fileSystems."/mnt/data04".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data05".device = "/dev/disk/by-uuid/d05b525e-89f5-4f90-88eb-96aa5ae1f4d9";
  fileSystems."/mnt/data05".fsType = "ext4";
  fileSystems."/mnt/data05".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data06".device = "/dev/disk/by-uuid/79a90551-c3f4-4f33-af7f-a56fffd9b6da";
  fileSystems."/mnt/data06".fsType = "ext4";
  fileSystems."/mnt/data06".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data07".device = "/dev/disk/by-uuid/27358321-f957-477a-8cde-03a94aafbe9d";
  fileSystems."/mnt/data07".fsType = "ext4";
  fileSystems."/mnt/data07".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data08".device = "/dev/disk/by-uuid/72dc661d-b13d-4ec0-9195-591b4f20b140";
  fileSystems."/mnt/data08".fsType = "ext4";
  fileSystems."/mnt/data08".options = [
    "users"
    "nofail"
  ];

  fileSystems."/mnt/data09".device = "/dev/disk/by-uuid/3bb35a33-0efe-4c07-81fb-38fb1d4864c1";
  fileSystems."/mnt/data09".fsType = "ext4";
  fileSystems."/mnt/data09".options = [
    "users"
    "nofail"
  ];

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
      d07 = "/mnt/data07";
      d08 = "/mnt/data08";
      d09 = "/mnt/data09";
    };
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/data01/.snapraid.content"
      "/mnt/data02/.snapraid.content"
      "/mnt/data03/.snapraid.content"
      "/mnt/data04/.snapraid.content"
      "/mnt/data05/.snapraid.content"
      "/mnt/data06/.snapraid.content"
      "/mnt/data07/.snapraid.content"
      "/mnt/data08/.snapraid.content"
      "/mnt/data09/.snapraid.content"
    ];
    parityFiles = [
      # define 2 parity disk, as ext4 has 16TB file size limit, split parity file for each disk.
      "/mnt/parity1/snapraid.parity1,/mnt/parity1/snapraid.parity2"
      "/mnt/parity2/snapraid.parity1,/mnt/parity2/snapraid.parity2"
    ];
    exclude = [
      # ".@__thumb/"
      # "/lost+found/"
      #
      # # macOS
      # ".AppleDouble"
      # "._AppleDouble"
      # ".DS_Store"
      # "._.DS_Store"
      # ".Thumbs.db"
      # ".fseventsd"
      # ".Spotlight-V100"
      # ".Trashes"
      # ".AppleDB"
    ];
    sync.interval = "03:00"; # sync daily
    scrub.interval = "Mon 12:00"; # scrub every 10 days
    # scrub.plan = 8;
  };

  # mergerfs
  fileSystems."/mnt/archive-0" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/data*";
    # https://trapexit.github.io/mergerfs/quickstart/#configuration
    options = [
      "minfreespace=10G"
      "cache.files=off"
      "dropcacheonclose=false"

      # nfs
      # https://trapexit.github.io/mergerfs/latest/remote_filesystems/#nfs
      "noforget"
      "inodecalc=path-hash"
    ];
  };

  # hack to fix permission issue
  system.activationScripts.fix-perm.text = ''
    # chmod 777 /mnt/data01
    # chmod 777 /mnt/data02
    # chmod 777 /mnt/data03
    # chmod 777 /mnt/data04
    # chmod 777 /mnt/data05
    # chmod 777 /mnt/data06
    # chmod 777 /mnt/data07
    # chmod 777 /mnt/data08
    # chmod 777 /mnt/data09
    chmod 777 /mnt/archive-0
  '';

  systemd.services.snapraid-sync.preStart = ''
    echo "check drive mount"
    /run/current-system/sw/bin/cat /mnt/data01/.snapraid.id | /run/current-system/sw/bin/grep data01
    /run/current-system/sw/bin/cat /mnt/data02/.snapraid.id | /run/current-system/sw/bin/grep data02
    /run/current-system/sw/bin/cat /mnt/data03/.snapraid.id | /run/current-system/sw/bin/grep data03
    /run/current-system/sw/bin/cat /mnt/data04/.snapraid.id | /run/current-system/sw/bin/grep data04
    /run/current-system/sw/bin/cat /mnt/data05/.snapraid.id | /run/current-system/sw/bin/grep data05
    /run/current-system/sw/bin/cat /mnt/data06/.snapraid.id | /run/current-system/sw/bin/grep data06
    /run/current-system/sw/bin/cat /mnt/data07/.snapraid.id | /run/current-system/sw/bin/grep data07
    /run/current-system/sw/bin/cat /mnt/data08/.snapraid.id | /run/current-system/sw/bin/grep data08
  '';

  systemd.services.snapraid-scrub.preStart = ''
    echo "check drive mount"
    /run/current-system/sw/bin/cat /mnt/data01/.snapraid.id | /run/current-system/sw/bin/grep data01
    /run/current-system/sw/bin/cat /mnt/data02/.snapraid.id | /run/current-system/sw/bin/grep data02
    /run/current-system/sw/bin/cat /mnt/data03/.snapraid.id | /run/current-system/sw/bin/grep data03
    /run/current-system/sw/bin/cat /mnt/data04/.snapraid.id | /run/current-system/sw/bin/grep data04
    /run/current-system/sw/bin/cat /mnt/data05/.snapraid.id | /run/current-system/sw/bin/grep data05
    /run/current-system/sw/bin/cat /mnt/data06/.snapraid.id | /run/current-system/sw/bin/grep data06
    /run/current-system/sw/bin/cat /mnt/data07/.snapraid.id | /run/current-system/sw/bin/grep data07
    /run/current-system/sw/bin/cat /mnt/data08/.snapraid.id | /run/current-system/sw/bin/grep data08
  '';

  systemd.services.snapraid-scrub.onFailure = [ "ntfy-system-critical@snapraid-scrub.service" ];
  systemd.services.snapraid-sync.onFailure = [ "ntfy-system-critical@snapraid-sync.service" ];

  systemd.services.snapraid-scrub.onSuccess = [ "ntfy-system@snapraid-scrub.service" ];
  systemd.services.snapraid-sync.onSuccess = [ "ntfy-system@snapraid-sync.service" ];

  systemd.services."dummy" = {
    enable = true;
    script = ''sleep 5; printf "ping"; exit 0'';
    onFailure = [ "ntfy-system-critical@dummy.service" ];
    onSuccess = [ "ntfy-system@dummy.service" ];
  };

  systemd.services."dummy-fail" = {
    enable = true;
    script = ''sleep 5; printf "ping"; exit 1'';
    onFailure = [ "ntfy-system-critical@dummy.service" ];
    onSuccess = [ "ntfy-system@dummy.service" ];
  };

  systemd.services."ntfy-system-critical@" = {
    enable = true;
    scriptArgs = "%i";
    script = ''
      journalctl -u "$1" --since "$(systemctl show "$1" --property=ConditionTimestamp --value)" -n 10 |
        ${pkgs.curl}/bin/curl -H "Priority: urgent" -H "Title: $HOSTNAME:$1" --data-binary @- "https://ntfy.xkor.stream/system-critical"
    '';
  };

  systemd.services."ntfy-system@" = {
    enable = true;
    scriptArgs = "%i";
    script = ''
      journalctl -u "$1" --since "$(systemctl show "$1" --property=ConditionTimestamp --value)" -n 10 |
        ${pkgs.curl}/bin/curl -H "Priority: min" -H "Title: $HOSTNAME:$1" --data-binary @- "https://ntfy.xkor.stream/system"
    '';
  };
}
