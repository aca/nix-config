{
  config,
  pkgs,
  lib,
  ...
}:
{
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  services.xrdp.openFirewall = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.i3}/bin/i3 -c ${./i3config}";
  services.displayManager.defaultSession = "none+i3";
  services.xserver = {
    enable = true;
    dpi = 220;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi
        dunst
        i3altlayout
        dmenu # application launcher most people use
        i3status # gives you the default i3 status bar
        i3blocks # if you are planning on using i3blocks over i3status
        xsel
      ];
    };
  };
}
