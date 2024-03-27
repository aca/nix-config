{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pkgs.unstable.go_1_22
    pkgs.unstable.gotests
    pkgs.unstable.gopls
    pkgs.unstable.gotestsum
    pkgs.unstable.gomodifytags
    pkgs.unstable.gofumpt

    sbomnix
    visidata
    # oracle-instantclient
    bfs

    dura
    nushell
    caddy
    ipinfo

    awscli2
    # azure-cli
    # azure-storage-azcopy
    oci-cli

    # scrcpy

    file

    # gcc
    gettext
    ninja
    lf
    meson
    pkg-config
    clang
    clang-tools_16
    gnumake
    cmake
    ncurses

    rustc
    cargo

    # nodejs_20
    # nodePackages_latest.node-gyp
    # nodePackages_latest.pnpm
    # nodePackages_latest.pyright
    # nodePackages_latest.fx
    # nodePackages_latest.prettier
    # nodePackages.yaml-language-server
    # nodePackages.vscode-langservers-extracted

    php82
    php82Packages.composer

    ruby
  ];
}
