{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  dotfiles = builtins.fetchGit {
    url = "https://github.com/aca/dotfiles";
    ref = "main";
    inherit (inputs.dotfiles) rev;
    submodules = true;
  };
in
{
  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      friendlyName = "test";
      inotify = "yes";
      media_dir = [
        "/home/rok/Downloads/tmp"
        # "/mnt/seedbox"
        # "/mnt/seedbox-impx"
        # "/mnt/archive-0/Youtube"
      ];
      db_dir = "/tmp/minidlna3";
      # inotify = true;
      # notifyInterval = 60;
      # port = 8200;
      # extraConfig = ''
      #   media_dir=/mnt/archive-0
      # '';
    };
  };

  programs.alvr.enable = true;
  programs.alvr.openFirewall = true;
  programs.steam.enable = true;


  services.samba.openFirewall = true;
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    settings = {
      shared = {
        path = "/home/rok/store/vm/shared";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "rok";
        "force group" = "users";
      };
    };
  };

  # services.wivrn = {
  #   enable = true;
  #   openFirewall = true;
  #
  #   # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
  #   # will automatically read this and work with WiVRn (Note: This does not currently
  #   # apply for games run in Valve's Proton)
  #   defaultRuntime = true;
  #
  #   # Run WiVRn as a systemd service on startup
  #   autoStart = true;
  #
  #   # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
  #   config = {
  #     enable = true;
  #     json = {
  #       # 1.0x foveation scaling
  #       scale = 1.0;
  #       # 100 Mb/s
  #       bitrate = 100000000;
  #       encoders = [
  #         {
  #           encoder = "vaapi";
  #           codec = "h265";
  #           # 1.0 x 1.0 scaling
  #           width = 1.0;
  #           height = 1.0;
  #           offset_x = 0.0;
  #           offset_y = 0.0;
  #         }
  #       ];
  #     };
  #   };
  # };

}
