{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.xdg.configHome}/elvish/rc.elv".text =
     (builtins.readFile ./rc.elv)
   + (builtins.readFile ./rc2.elv)
   + (builtins.readFile ./bind.elv)
   + (builtins.readFile ./interactive.elv)
   + (builtins.readFile ./prompt.elv)
;
}
