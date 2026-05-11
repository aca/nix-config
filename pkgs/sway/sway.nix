{
  config,
  pkgs,
  lib,
  ...
}:
let
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock.enableGnomeKeyring = true;
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # Enabling realtime may improve latency and reduce stuttering, specially in high load scenarios.
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Dracula'
      '';
  };
in
{
  environment.systemPackages = with pkgs; [
    (import ./sway-workspace.nix)

    # alacritty # gpu accelerated terminal
    # bemenu # wayland clone of dmenu
    # gnome3.adwaita-icon-theme # default gnome cursors
    # gnome3.adwaita-icon-theme # default gnome cursors
    # mako # notification system developed by swaywm maintainer
    # pavucontrol
    # pulseaudio
    # xord-xwayland
    bemenu # wayland clone of dmenu
    clipman
    configure-gtk
    dbus-sway-environment
    dracula-theme # gtk theme
    dragon-drop
    dunst
    easyeffects
    glib # gsettings
    grim # screenshot
    kanshi
    kanshi
    libnotify
    pavucontrol
    pulseaudioFull
    pwvucontrol
    rofi
    rustc
    slurp # screenshot
    spice-vdagent
    sway
    swaybg
    swayidle
    swaylock-effects
    wayland
    waypipe
    wdisplays # tool to configure displays
    wl-clipboard
    xdg-utils # for opening default programs when clicking links
  ];

  security.rtkit.enable = true;
  # hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      # support32Bit = true;
    };
    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.quantum" = 1024; # 버퍼 크기 늘리기 (안정성↑)
          "default.clock.min-quantum" = 512;
        };
      };
    };
    wireplumber.enable = true;
    # jack.enable = true;
  };

  # # # https://nixos.wiki/wiki/PipeWire
  # services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
  #   "monitor.bluez.properties" = {
  #     "bluez5.enable-sbc-xq" = true; # SBC-XQ sounds better
  #     "bluez5.enable-msbc" = true;
  #     "bluez5.enable-hw-volume" = true;
  #     "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
  #   };
  # };

  services.pipewire.wireplumber.configPackages = [
    # (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/59-systemwide-bluetooth.conf" ''
    #   wireplumber.profiles = {
    #     main = {
    #       monitor.bluez.seat-monitoring = disabled
    #     }
    #   }
    # '')

    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
      monitor.bluez.properties = {
        bluez_monitor.enabled = true
        bluez5.enable-sbc-xq = true
        bluez5.enable-msbc = true
        bluez5.enable-hw-volume = true
        bluez5.headset-roles = [hsp_hs hsp_ag hfp_hf hfp_ag]
      }
    '')
  ];

  # services.pipewire.extraConfig.pipewire."92-low-latency" = {
  #   context.properties = {
  #     default.clock.rate = 48000;
  #     default.clock.quantum = 32;
  #     default.clock.min-quantum = 32;
  #     default.clock.max-quantum = 32;
  #   };
  # };

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    # extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  environment.variables."XDG_CURRENT_DESKTOP" = "sway";
  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      xwayland # Explicitly ensure xwayland is available
      xorg.xauth
    ];
  };
}
