{
  config,
  pkgs,
  lib,
  ...
}:
{
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  services.xrdp.enable = true;
  services.xrdp.openFirewall = true;
  # services.xrdp.defaultWindowManager = "/run/current-system/sw/bin/lxqt-session";
  services.xrdp.defaultWindowManager = "/run/current-system/sw/bin/enlightenment_start";
  services.xserver.enable = true;
  # services.xserver.desktopManager.lxqt.enable = true;
  # services.xserver.desktopManager.lxqt.enable = true;
  environment.enlightenment.excludePackages = [
    pkgs.enlightenment.econnman
  ];

  services.xserver.desktopManager.enlightenment.enable = true;
}
