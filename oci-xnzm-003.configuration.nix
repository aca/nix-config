{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware/oci-xnzm-003.nix
  ];

  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };

  boot.loader.grub.configurationLimit = 1;

  system.stateVersion = "24.11";

  networking.hostName = "oci-xnzm-003";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = ["--ssh" "--advertise-exit-node=true"];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    (import ./keys.nix).seedbox
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  zramSwap.enable = true;

  # services.github-runner = {
  #   enable = true;
  #   url = ''https://github.com/investing-kr/oci-arm-host-capacity'';
  #   tokenFile = ''/root/.github'';
  #   name = ''oci-xnzm-003'';
  #   replace = true;
  #   extraLabels = [ "nix" ];
  #   extraPackages = with pkgs; [
  #     php82
  #     php82Packages.composer
  #   ];
  # };

  networking.firewall.enable = false;

  # nixpkgs.config.permittedInsecurePackages = ["nodejs-16.20.1"];

  environment.systemPackages = with pkgs; [
    fzf
    git
    tailscale
    tmux
    ttyd
    jq
    # gcc
    # go
    fd
    # nodejs_20
    inetutils
    aria2
    elvish
    vifm
    # php82
    # php82Packages.composer
    wget
    coreutils-full
    moreutils
    glibcLocales
    # ghq
    stow
    iftop
    glances
    gnumake
    entr
    procps
    vim
    zsh
    fish
    xsel
  ];
}
