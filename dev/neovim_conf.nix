{
  pkgs,
  ...
}:
rec {
  systemd.services."nvim-rebuild" = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      WorkingDirectory = "/home/rok/.config/nvim";
      Restart = "always";
    };
    path = [
      pkgs.fd
      pkgs.luajit
      pkgs.luajitPackages.stdlib
      pkgs.entr
      pkgs.bash
    ];
    startLimitIntervalSec = 10;
    script = ''
      fd --type f --extension lua . init | timeout 10m entr -n -r bash -c "cat init/*.lua | luajit -b - init.lua"
    '';
  };

  systemd.services."nvim-rebuild-lazy" = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      WorkingDirectory = "/home/rok/.config/nvim";
      Restart = "always";
    };
    path = [
      pkgs.fd
      pkgs.luajit
      pkgs.luajitPackages.stdlib
      pkgs.entr
      pkgs.bash
    ];
    startLimitIntervalSec = 10;
    script = ''
      fd --type f --extension lua . lazy | timeout 10m entr -n -r bash -c "cat lazy/*.lua | luajit -b - lua/init-lazy.lua"
    '';
  };
}
