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
    nixfmt-rfc-style
    alejandra
    home-manager
  ];
}
