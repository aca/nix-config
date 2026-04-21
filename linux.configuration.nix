{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}:
let
in
{
  # home
  networking.hosts."100.127.31.30" = [ "git.internal" ];
  # oci-aca-001
  networking.hosts."100.97.173.112" = [ "claude-ocr.internal" ];

  environment.enableAllTerminfo = true;



  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Asia/Seoul";

  # source secret env globally
  environment.extraInit = ''
    set -o allexport
    if [ -f "/run/agenix/env" ]; then
      source "/run/agenix/env"
    fi
    set +o allexport
  '';

  # enable direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # nix.settings.experimental-features = "nix-command flakes";
  # nix.settings.trusted-users = [
  #   "root"
  #   "rok"
  # ];

  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 14d";
  # };

  nixpkgs.config.permittedInsecurePackages = [
    # matrix issue?
    "olm-3.2.16"
  ];

  # - The option definition `systemd.extraConfig' in `/nix/store/3kl5f4l6apvv0binfkwnmaici0klfasw-source/linux.configuration.nix' no longer has any effect; please remove it.
  # Use systemd.settings.Manager instead.
  # systemd.extraConfig = ''
  #   DefaultTimeoutStopSec=240s
  # '';

  services.openssh.enable = true;

  programs.git = {
    enable = true;
    config = {
      core = {
        sharedrepository = 1;
      };
      init = {
        defaultBranch = "main";
      };
      http = {
        receivepack = true;
      };
      safe = {
        directory = "*";
      };
      pull = {
        ff = "only";
      };
      # "url \"ssh://rok@github.com/home/rok/src\"" = {
      #   "insteadOf" = "https://git.internal.home";
      # };
    };
  };

  security.sudo.wheelNeedsPassword = false;

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

  # services.fwupd.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.containers.policy = {
    default = [ { type = "insecureAcceptAnything"; } ];
    transports = {
      docker-daemon = {
        "" = [ { type = "insecureAcceptAnything"; } ];
      };
    };
  };

  systemd.tmpfiles.settings."logs" = {
    "/logs" = {
      d.mode = "0777";
    };
    "/logs/active" = {
      d.mode = "0777";
    };
  };
  # systemd.tmpfiles.settings."kv" = {
  #   "/var/cache/kv" = {
  #     d.mode = "0777";
  #   };
  # };

  # environment.systemPackages = [
  #   pkgs.ntfy-sh
  #   pkgs.diskus
  #   pkgs.fd
  #   pkgs.ncdu
  #   pkgs.expect
  #   pkgs.pstree
  # ];

  systemd.services."notify-send-fail@" = {
    enable = true;
    description = "service fail notification for %i";
    scriptArgs = "%i";
    script = ''
      notify-send -u critical "$1"
    '';
  };

  # security.pki.certificateFiles = [
  #   ./certs/mkcert/rootCA.pem
  # ];

  services.vector.journaldAccess = true;
  # services.vector.enable = true;
}
