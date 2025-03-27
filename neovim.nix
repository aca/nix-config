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
    # (_: super: {
    #   neovim =
    #     pkgs.wrapNeovim inputs.neovim.packages.${system}.default {
    #     };
    # })

    (_: super: {
      neovim =
        pkgs.wrapNeovimUnstable inputs.neovim.packages.${system}.default
          (
            pkgs.neovimUtils.makeNeovimConfig {
              wrapRc = false;
              extraLuaPackages = p: [ p.magick ];
              extraPackages = p: [ p.imagemagick ];
              # plugins = [
              #   {
              #     plugin = inputs.nixpkgs-unstable.pakcages.vimPlugins.blink-cmp;
              #     optional = false;
              #   }
              # ];
            }
          );
    })
  ];
}
