{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  overlays = system: [
    (final: prev: {
      go-nightly = inputs.nixpkgs-unstable.legacyPackages.${system}.go;
    })
  ];
in
rec {
  # use pkgs.stdenv.hostPlatform.system instead of `system` from specialArgs
  # because `system` arg to nixpkgs.lib.nixosSystem is deprecated in 25.11
  nixpkgs.overlays = overlays pkgs.stdenv.hostPlatform.system;
  nixpkgs.config.permittedInsecurePackages = [
    # services.matrix issue?
    "olm-3.2.16"
  ];
}
