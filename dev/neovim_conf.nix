{ pkgs, ... }:
rec {
  # systemd.services."nvim-rebuild" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     Restart = "always";
  #   };
  #   path = [
  #     pkgs.fd
  #     pkgs.luajit
  #     pkgs.luajitPackages.stdlib
  #     pkgs.entr
  #     pkgs.bash
  #   ];
  #   startLimitIntervalSec = 10;
  #   script = ''
  #     ${pkgs.watchexec}/bin/watchexec --watch /home/rok/.config/nvim/init --notify '/home/rok/.config/nvim/init/build.sh'
  #   '';
  # };
  #
  # systemd.services."nvim-rebuild-lazy" = {
  #   enable = true;
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     Restart = "always";
  #   };
  #   path = [
  #     pkgs.fd
  #     pkgs.luajit
  #     pkgs.luajitPackages.stdlib
  #     pkgs.entr
  #     pkgs.bash
  #   ];
  #   startLimitIntervalSec = 10;
  #   script = ''
  #     ${pkgs.watchexec}/bin/watchexec --watch /home/rok/.config/nvim/lazy --notify '/home/rok/.config/nvim/lazy/build.sh'
  #   '';
  # };
}
