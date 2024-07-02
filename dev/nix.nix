{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    fh
    nix-index
    devbox
    home-manager
    # pkgs.unstable.attic-server
    # pkgs.unstable.attic-client
    # nil # nix language server 
  ];
}
