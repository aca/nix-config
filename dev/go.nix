{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    gotests
    gopls
    go_1_23
    gotestsum
    gomodifytags
    gofumpt
    sqlc
    golangci-lint
    sbomnix

    sbomnix
    # visidata
    # oracle-instantclient
    bfs

    # dura
    # nushell
    # caddy
    # ipinfo

    # awscli2
    # azure-cli
    # azure-storage-azcopy
    # oci-cli

    pkgs.file
    pkgs.gettext
    pkgs.ninja
    pkgs.lf
    pkgs.meson
    pkgs.clang
    pkgs.clang-tools_16
    pkgs.gnumake
    pkgs.cmake
    pkgs.ncurses

    # nodejs_20
    # nodePackages_latest.node-gyp
    # nodePackages_latest.pnpm
    # nodePackages_latest.pyright
    # nodePackages_latest.fx
    # nodePackages_latest.prettier
    # nodePackages.yaml-language-server
    # nodePackages.vscode-langservers-extracted
  ];
}
