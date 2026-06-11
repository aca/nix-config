{pkgs ? import <nixpkgs> {}}:
pkgs.buildGoModule rec {
  name = "qbt";
  version = "0.1";
  subPackages = "cmd/qbt";
  vendorHash = "sha256-PFI5pcwLdE/OBElwV8tm/ganH3/PI6/mCSKn6MKvIgg=";
  src = pkgs.fetchFromGitHub {
    owner = "aca";
    repo = "qbittorrent-cli";
    rev = "f05caeb4c3dab4ccd60f184a53799e565be1c487";
    hash = "sha256-jfPG2golNccq9BGqU37d6zICBUcaOy5HlVMHJwZGNqA=";
    # inherit (inputs.qbt-src) rev;
    # hash = inputs.qbt-src.narHash;
  };
}
#   # https://phip1611.de/blog/accessing-network-from-a-nix-derivation/
#   stdenv.mkDerivation rec {
#     __impure = true; # marks this derivation as impure
#     name = "qbt";
#     version = "0.1";
#     src = pkgs.fetchFromGitHub {
#       owner = "aca";
#       repo = "qbittorrent-cli";
#       inherit (inputs.qbt-src) rev;
#       hash = inputs.qbt-src.narHash;
#     };
#     buildInputs = with pkgs; [go];
#     buildPhase = ''
#       export GOPATH=$out/share/go
#       export GOCACHE=$TMPDIR/go-cache
#       go build ./cmd/qbt qbt
#     '';
#     installPhase = ''
#       mkdir -p $out/bin
#       cp qbt $out/bin
#     '';
#     # builder = ''
#     #   ls
#     #   go build ./cmd/qbt -o $out/bin/qbt
#     # '';
#     # dontBuild = true;
#   }

