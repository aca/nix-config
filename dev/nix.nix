{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    fh # flakehub
    nix-index
    # devbox
    # agenix
    attic-client
    attic-server
    nixd
    # nixVersions.latest
    nixfmt-rfc-style
    nix-tree
    alejandra
    home-manager
    # devenv
  ];
}
