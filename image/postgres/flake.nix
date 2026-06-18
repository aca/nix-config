{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems f;

      mkSystem = system: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/docker-image.nix"
          ./configuration.nix
        ];
      };
    in {
      packages = forAll (system: {
        dockerImage = (mkSystem system).config.system.build.tarball;
      });
    };
}
