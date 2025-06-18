{
  config,
  pkgs,
  system,
  ...
}:
let
in
{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "python" ''
      exec uv run python "$@"
    '')

    (pkgs.writeShellScriptBin "python3" ''
      exec uv run python "$@"
    '')

    (pkgs.writeShellScriptBin "py" ''
      exec uv run python "$@"
    '')

    (pkgs.buildFHSEnv {
      name = "uv";
      targetPkgs =
        pkgs: with pkgs; [
          uv
          python3
          gcc
          binutils

          zlib
          bzip2
          readline
          openssl
          gdbm
          ncurses
          sqlite
          tk
          libffi
          expat
          xz

          # numpy
          blas
          lapack
          gfortran

          stdenv.cc.cc.lib
          libxml2
          libxslt
          curl
          git
        ];

      runScript = "uv";

      profile = ''
        export LD_LIBRARY_PATH=/lib:/lib64:$LD_LIBRARY_PATH
        export LIBRARY_PATH=/lib:/lib64:$LIBRARY_PATH
        export C_INCLUDE_PATH=/include:$C_INCLUDE_PATH
        export CPLUS_INCLUDE_PATH=/include:$CPLUS_INCLUDE_PATH
        export PKG_CONFIG_PATH=/lib/pkgconfig:$PKG_CONFIG_PATH
      '';
    })
  ];
}
