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
    nixd
    # nixVersions.latest
    nixfmt-rfc-style
      nix-tree
    alejandra
    home-manager
    devenv
  ];
}
