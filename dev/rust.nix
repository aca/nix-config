{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # rust-analyzer
  ];
}
