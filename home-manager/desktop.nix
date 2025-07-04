{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
in
{
  imports = [
    # ./firefox/firefox.nix
  ];

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "IosevkaTermSlab Nerd Font:size=24";
      };
      colors = {
        background = "000000";
        foreground = "b9b9b9";
        regular0 = "252525";
        regular1 = "ed4a46";
        regular2 = "70b433";
        regular3 = "dbb32d";
        regular4 = "368aeb";
        regular5 = "eb6eb7";
        regular6 = "3fc5b7";
        regular7 = "777777";
        bright0 = "3b3b3b";
        bright1 = "ff5e56";
        bright2 = "83c746";
        bright3 = "efc541";
        bright4 = "4f9cfe";
        bright5 = "ff81ca";
        bright6 = "56d8c9";
        bright7 = "dedede";
      };
    };
  };

  home.file."${config.xdg.configHome}/kime/config.yaml".text = builtins.readFile ./kime.config.yaml;

  # home.stateVersion = "25.05";
  # home.username = "rok";
}
