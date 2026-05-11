{
  config,
  pkgs,
  ...
}:
{
  services.xrdp.enable = true;
  services.xrdp.openFirewall = true;
  services.xrdp.defaultWindowManager = "/run/current-system/sw/bin/enlightenment_start";
  services.xserver.enable = true;
  environment.enlightenment.excludePackages = [
    pkgs.enlightenment.econnman
  ];

  services.xserver.desktopManager.enlightenment.enable = true;

  fonts.packages = with pkgs; [
    cm_unicode
    noto-fonts-cjk-sans
    ibm-plex
  ];
}
