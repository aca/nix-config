{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  mkUvFHS =
    name:
    pkgs.buildFHSEnv {
      inherit name;
      runScript = name;
      targetPkgs =
        pkgs: with pkgs; [
          uv
          gcc
          binutils

          libgcc
          zlib
          bzip2
          zstd
          readline
          openssl
          swig
          gdbm
          ncurses
          sqlite
          tk
          libffi
          # expat
          xz

          blas
          lapack
          gfortran

          stdenv.cc.cc.lib
          libxml2
          libxslt
          curl
          git
        ];
      profile = ''
        export LD_LIBRARY_PATH=/lib:/lib64:$LD_LIBRARY_PATH
        export LIBRARY_PATH=/lib:/lib64:$LIBRARY_PATH
        export C_INCLUDE_PATH=/include:$C_INCLUDE_PATH
        export CPLUS_INCLUDE_PATH=/include:$CPLUS_INCLUDE_PATH
        export PKG_CONFIG_PATH=/lib/pkgconfig:$PKG_CONFIG_PATH
      '';
    };
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "py" ''
      exec uv run python "$@"
    '')

    (mkUvFHS "uvx")
    (mkUvFHS "uv")

    (pkgs.buildFHSEnv {
      name = "fhstest";
      runScript = "bash";
      targetPkgs =
        pkgs: with pkgs; [
            bash
        ];
    })
  ];
}
