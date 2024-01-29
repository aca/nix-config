{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    nil # nix language server 
  ];
}
