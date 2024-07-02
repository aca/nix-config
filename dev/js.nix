{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pkgs.unstable.bun
    # nodePackages."@vtsls/language-server"
    # nodePackages.pnpm

      # pkgs.unstable.nodejs
      # pkgs.unstable.node2nix
      # pkgs.unstable.quickemu
      # pkgs.unstable.nodePackages_latest.node-gyp
      # pkgs.unstable.nodePackages_latest.pnpm
      # # pkgs.unstable.nodePackages_latest.tree-sitter-cli
      # pkgs.unstable.nodePackages_latest.pyright
      # pkgs.unstable.nodePackages_latest.fx
      # pkgs.unstable.nodePackages_latest.prettier
      # pkgs.unstable.nodePackages_latest.yaml-language-server
      # pkgs.unstable.nodePackages_latest.vscode-langservers-extracted
  ];
}
