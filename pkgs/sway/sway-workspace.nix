with import <nixpkgs> {}; let
in
  pkgs.rustPlatform.buildRustPackage rec {
    name = "sway-workspace";
    version = "0.2.3";
    # subPackages = "cmd/qbt";
    # vendorHash = "sha256-PFI5pcwLdE/OBElwV8tm/ganH3/PI6/mCSKn6MKvIgg=";
    # https://github.com/matejc/sway-workspace/releases/tag/v0.2.3
    doCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "matejc";
      repo = "sway-workspace";
      rev = "master";
      hash = "sha256-8rxO/jvLLRwU7LVX4UxA65+/1BI3rK5uJXkKIGbs5as=";
      # inherit (inputs.sway-workspace) rev;
      # hash = inputs.sway-workspace.narHash;
    };
    cargoHash = "sha256-yHDOmqaU8kw8Kzjf1ouubl8F4zRmfezJZbYsWKsetO8=";
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

