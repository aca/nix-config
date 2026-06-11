{
  lib,
  stdenv,
  fetchFromGitHub,
  nix,
  cmake,
  pkg-config,
  boost,
}:

stdenv.mkDerivation rec {
  pname = "nix-plugins";
  version = "15.0.0";

  src = fetchFromGitHub {
    owner = "aca";
    repo = "nix-plugins";
    rev = "a5e5ac4471a2a1e079e11a9c761c0e2cb145c245";
    hash = "sha256-1hP5PzH2bYDka7CkksZh88jKCzlSs/m4M+GmZwWjln4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    nix
    boost
  ];

  meta = {
    description = "Collection of miscellaneous plugins for the nix expression language";
    homepage = "https://github.com/shlevy/nix-plugins";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
