{ config, pkgs, ... }:
{
  services.transmission = {
    enable = true;
    settings = {
      # mkdir -p /home/rok/Downloads/transmission/.tmp
      download-dir = "/home/rok/Downloads/transmission";
      incomplete-dir = "/home/rok/Downloads/transmission/.tmp";
      incomplete-dir-enabled = true;
    };
  };
}
