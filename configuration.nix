{
  config,
  pkgs,
  options,
  inputs,
  nix,
  lib,
  ...
}@args:
let
in
{
  nix.settings = {
    # plugin-files = "${pkgs.nix-plugins}/lib/nix/plugins/libnix-extra-builtins.so";
    # extra-builtins-file = [ ./lib/extra-builtins.nix ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  # programs.direnv = {
  #   nix-direnv.enable = true;
  # };

  # programs.bash.shellInit = ''
  #   VTE_VERSION=9999
  # '';
  # programs.bash.vteIntegration = true;
  # programs.bash.interactiveShellInit = ''
  #   VTE_VERSION=9999
  # '';
}
