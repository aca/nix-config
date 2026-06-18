{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  systemd.user.services."nvim-rebuild" = {
    Service = {
      WorkingDirectory = "${config.xdg.configHome}/nvim/init";
      ExecStart = ''
        ${pkgs.watchexec}/bin/watchexec --notify 'cat *.lua | luajit -b - ../init.lua'
      '';
      Restart = "always";
      StartLimitIntervalSec = 10;
      Environment = "PATH=${
        pkgs.lib.makeBinPath [
          (pkgs.luajit.withPackages (
            p: with p; [
              stdlib
              luarocks
            ]
          ))
          pkgs.bash
          pkgs.coreutils
        ]
      }";
    };
  };

  systemd.user.services."nvim-rebuild-lazy" = {
    Service = {
      WorkingDirectory = "${config.xdg.configHome}/nvim/lazy";
      ExecStart = ''
        ${pkgs.watchexec}/bin/watchexec --notify 'cat *.lua | luajit -b - ../lua/lazy.lua'
      '';
      Restart = "always";
      StartLimitIntervalSec = 10;
      Environment = "PATH=${
        pkgs.lib.makeBinPath [
          (pkgs.luajit.withPackages (
            p: with p; [
              stdlib
              luarocks
            ]
          ))
          pkgs.bash
          pkgs.coreutils
        ]
      }";
    };
  };
}
