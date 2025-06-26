{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    gotests
    gopls
    go
    gotestsum
    gomodifytags
    gofumpt
    sqlc
    golangci-lint
    sbomnix

    # visidata
    # oracle-instantclient

    # dura
    # nushell
    # caddy
    # ipinfo

    # awscli2
    # azure-cli
    # azure-storage-azcopy
    # oci-cli

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
