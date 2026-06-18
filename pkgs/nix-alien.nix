{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien
  ];

  # Optional, but this is needed for `nix-alien-ld` command
  programs.nix-ld.enable = true;
}
