{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  services.displayManager = {
    defaultSession = "none+i3";
  };

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = true;
    };

    dpi = 220;

    windowManager.i3 = {
      configFile = ./i3config;
      enable = true;
      extraPackages = with pkgs; [
        rofi
        dunst
        scrot
        i3altlayout
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
        arandr
        xorg.xev
        espeak
        xsel
        xdragon
        grim
      ];
    };
  };
}
