with import <nixpkgs> {}; # bring all of Nixpkgs into scope

  let
  in
    stdenv.mkDerivation rec {
      name = "hello-2.8";
      src = fetchurl {
        url = "mirror://gnu/hello/${name}.tar.gz";
        sha256 = "0wqd8sjmxfskrflaxywc7gqw7sfawrfvdxd9skxawzfgyy0pzdz6";
      };
    }
