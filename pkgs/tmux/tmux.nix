{
  config,
  pkgs,
  lib,
  ...
}: let
  # tmux-fuzzback = pkgs.stdenv.mkDerivation {
  #   name = "tmux-fuzzback";
  #   src = pkgs.lib.fileset.toSource {
  #     root = ./nop;
  #     # fileset = ./.;
  #   };
  # };
  # "xxx".source = "./nop";
  tmux-fuzzback = fetchGit {
    url = "https://github.com/roosta/tmux-fuzzback";
    ref = "main";
    rev = "48fa13a2422bab9832543df1c6b4e9c6393e647c";
  };
in {
  programs.tmux = {
    enable = true;
    # clock24 = true;
    extraConfig =
      builtins.readFile ./tmux.conf
      + ''
        run-shell ${tmux-fuzzback}/fuzzback.tmux
      '';
  };
}
