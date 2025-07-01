{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
in
{
  # (pkgs.writeShellScriptBin "python" ''
  #   export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
  #   exec ${pkgs.python3}/bin/python "$@"
  # '')
  #
  # (pkgs.writeShellScriptBin "python3" ''
  #   export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
  #   exec ${pkgs.python3}/bin/python "$@"
  # '')
  home.packages = [
    #
    # (pkgs.writeShellScriptBin "python" ''
    #   exec uv run python "$@"
    # '')
    #
    # (pkgs.writeShellScriptBin "python3" ''
    #   exec uv run python "$@"
    # '')
    #
    # (pkgs.writeShellScriptBin "py" ''
    #   exec uv run python "$@"
    # '')
    #
    # # uv를 위한 더 완전한 FHS 환경
    # (pkgs.buildFHSEnv {
    #   name = "uv";
    #   targetPkgs =
    #     pkgs: with pkgs; [
    #       uv
    #       python3
    #       gcc
    #       binutils
    #
    #       # Python 패키지들이 필요로 하는 라이브러리들
    #       zlib
    #       bzip2
    #       readline
    #       openssl
    #       gdbm
    #       ncurses
    #       sqlite
    #       tk
    #       libffi
    #       expat
    #       xz
    #
    #       # numpy 등 과학 계산 패키지를 위한 추가 라이브러리
    #       blas
    #       lapack
    #       gfortran
    #
    #       # 기타 유용한 라이브러리들
    #       stdenv.cc.cc.lib
    #       libxml2
    #       libxslt
    #       curl
    #       git
    #     ];
    #
    #   # FHS 환경에서 실행할 명령
    #   runScript = "uv";
    #
    #   # 환경 변수 설정
    #   profile = ''
    #     export LD_LIBRARY_PATH=/lib:/lib64:$LD_LIBRARY_PATH
    #     export LIBRARY_PATH=/lib:/lib64:$LIBRARY_PATH
    #     export C_INCLUDE_PATH=/include:$C_INCLUDE_PATH
    #     export CPLUS_INCLUDE_PATH=/include:$CPLUS_INCLUDE_PATH
    #     export PKG_CONFIG_PATH=/lib/pkgconfig:$PKG_CONFIG_PATH
    #   '';
    # })
  ];
}
