{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}:
rec {
  nixpkgs.overlays = [
    # https://github.com/neovim/neovim/pull/27855/commits
    (final: prev: {
      neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          # rev = "3cdb84e0c694e9f321dbe41c1111d0846c1beb03";
          # hash = "sha256-dwVI9U3wTXBuvhPnobyLy//2yHNDaQFYWUNImakz0cQ=";
          inherit (inputs.neovim) rev;
          hash = inputs.neovim.narHash;
        };
        nativeInstallCheckInputs = [ ];
      });
    })

    # (_: super: {
    #   neovim =
    #     pkgs.wrapNeovim inputs.neovim.packages.${system}.default {
    #     };
    # })

    # (_: super: {
    #   neovim =
    #     pkgs.wrapNeovimUnstable inputs.neovim.packages.${system}.default
    #     (
    #       pkgs.neovimUtils.makeNeovimConfig {
    #         wrapRc = false;
    #         extraLuaPackages = p: [p.magick];
    #         extraPackages = p: [p.imagemagick];
    #         # plugins = [
    #         #   {
    #         #     plugin = inputs.nixpkgs-unstable.pakcages.vimPlugins.blink-cmp;
    #         #     optional = false;
    #         #   }
    #         # ];
    #       }
    #     );
    # })
  ];

            environment.systemPackages = [
pkgs.neovim-unwrapped
            ];
}
