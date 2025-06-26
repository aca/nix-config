{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
let
  # not work, under /home/$USER, use home-manager
  # systemd.tmpfiles.rules = [
  #   # 형식: "d <path> <mode> <uid> <gid> <age>"
  #   # %u → 실제 사용자 이름, %h → 사용자 홈 디렉토리
  #   "d /home/%u/src 0755 - - -"
  # ];
  systemd.tmpfiles.settings."logs" = {
    "/logs" = {
      d.mode = "0777";
    };
    "/logs/active" = {
      d.mode = "0777";
    };
  };

  # osc7
  # programs.bash.enable = true;
  # programs.bash.vteIntegration = true;
  programs.fish.enable = true;
  # programs.zsh.enable = true;
  # programs.bash.vteIntegration = true;
  # programs.zsh.vteIntegration = true;

  useunstable = system: pkg: { ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg}; };
  usenightly = system: pkg: { ${pkg} = inputs.nixpkgs-nightly.legacyPackages.${system}.${pkg}; };

  services.openssh.settings.PasswordAuthentication = false;

  # vaultix, not sure it works
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  # nix.settings.experimental-features = "nix-command flakes";
  # nix.extraOptions = ''
  #   experimental-features = nix-command flakes
  # '';
  # nix.extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
  #    "experimental-features = nix-command flakes";
  # nix.settings.experimental-features = "nix-command flakes";
  # system.activationScripts."update-hosts" = ''
  #   cat /etc/hosts > /etc/hosts.bak
  #   rm /etc/hosts
  #   cat /etc/hosts.bak "${config.age.secrets."hosts".path}" >> /etc/hosts
  # '';
in
rec {
  systemd.extraConfig = ''
    #  DefaultTimeoutStopSec=240s
  '';

  services.openssh.enable = true;

  # programs.git = {
  #   enable = true;
  #   config = {
  #     core = {
  #       sharedrepository = 1;
  #     };
  #     init = {
  #       defaultBranch = "main";
  #     };
  #     http = {
  #       receivepack = true;
  #     };
  #     safe = {
  #       directory = "*";
  #     };
  #     pull = {
  #       ff = "only";
  #     };
  #     "url \"ssh://rok@github.com/home/rok/src\"" = {
  #       "insteadOf" = "https://git.internal.home";
  #     };
  #   };
  # };

  # security.sudo.wheelNeedsPassword = false;
  # services.gnome.gnome-keyring.enable = true;

  imports = [
    ./env.nix
    ./dev/default_ssh.nix
    ./pkgs/scripts.nix
    ./pkgs/tmux/tmux.nix
  ];

  # Disable wait online as it's causing trouble at rebuild
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.systemd-udevd.restartIfChanged = false;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # i18n.defaultLocale = "en_US.UTF-8";
  # i18n.extraLocaleSettings = {
  #   # LC_ADDRESS = "en_US.UTF-8";
  #   # LC_IDENTIFICATION = "en_US.UTF-8";
  #   # LC_MEASUREMENT = "en_US.UTF-8";
  #   # LC_MONETARY = "en_US.UTF-8";
  #   # LC_NAME = "en_US.UTF-8";
  #   # LC_NUMERIC = "en_US.UTF-8";
  #   # LC_PAPER = "en_US.UTF-8";
  #   # LC_TELEPHONE = "en_US.UTF-8";
  #   # LC_TIME = "en_US.UTF-8";
  #   # LC_ADDRESS = "en_US.UTF-8";
  #   # LC_IDENTIFICATION = "en_US.UTF-8";
  #   # LC_MEASUREMENT = "en_US.UTF-8";
  #   # LC_MONETARY = "en_US.UTF-8";
  #   # LC_NAME = "en_US.UTF-8";
  #   # LC_NUMERIC = "en_US.UTF-8";
  #   # LC_PAPER = "en_US.UTF-8";
  #   # LC_TELEPHONE = "en_US.UTF-8";
  #   # LC_TIME = "en_US.UTF-8";
  # };

  time.timeZone = "Asia/Seoul";

  # services.fwupd.enable = true;

  # virtualisation.containers.enable = true;
  # virtualisation.containers.policy = {
  #   default = [{type = "insecureAcceptAnything";}];
  #   transports = {
  #     docker-daemon = {
  #       "" = [{type = "insecureAcceptAnything";}];
  #     };
  #   };
  # };

  systemd.tmpfiles.settings."logs" = {
    "/logs" = {
      d.mode = "0777";
    };
    "/logs/active" = {
      d.mode = "0777";
    };
  };
  systemd.tmpfiles.settings."kv" = {
    "/var/cache/kv" = {
      d.mode = "0777";
    };
  };

  environment.systemPackages = [
    # inputs.zig.packages.x86_64-linux.master
    # pkgs.ntfy-sh
    pkgs.ripgrep
    pkgs.git
    pkgs.vifm
    pkgs.pstree
    pkgs.diskus
    pkgs.fd
    # pkgs.yazi
    pkgs.age
    pkgs.ncdu
    # pkgs.xcp
    pkgs.expect
    # pkgs.passage
  ];

  # networking.hosts = {
  #   "100.127.31.30" = [ "git.internal" ];
  # };

  systemd.services."notify-send-fail@" = {
    enable = true;
    description = "service fail notification for %i";
    scriptArgs = "%i";
    script = ''
      notify-send -u critical "$1"
    '';
  };

  # programs.direnv = {
  #   enable = true;
  #   nix-direnv.enable = true;
  # };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  security.pki.certificateFiles = [
    ./certs/mkcert/rootCA.pem
    ./certs/x/1.crt
    ./certs/x/2.crt
  ];
}
