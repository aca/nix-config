with import <nixpkgs> {}; let
  advcpmv_owner = "jarun";
  advcpmv_version = "0.9";
  coreutils_version = "9.5";
  coreutils_upstream = "coreutils";
  patch_rev = "1e2b1c6b74fa0974896bf94604279a3f74b37a63";
in
  stdenv.mkDerivation rec {
    name = "advcpmv";
    version = advcpmv_version;

    src = fetchurl {
      name = "source-${name}-${coreutils_version}.tar.xz";
      url = "ftp://ftp.gnu.org/gnu/${coreutils_upstream}/${coreutils_upstream}-${coreutils_version}.tar.xz";
      sha256 = "sha256-zTKO3qyS9qZl3p8yPJO3Eq8YWLwuDYjz9xAEaUcKG4o=";
    };

    patches = [
      (fetchpatch {
        url = "https://raw.githubusercontent.com/${advcpmv_owner}/${name}/${patch_rev}/${name}-${advcpmv_version}-${coreutils_version}.patch";
        sha256 = "sha256-LRfb4heZlAUKiXl/hC/HgoqeGMxCt8ruBYZUrbzSH+Y=";
      })
    ];

    installPhase = ''
      install -D "src/cp" "$out/bin/advcp"
      install -D "src/mv" "$out/bin/advmv"
    '';
  }
