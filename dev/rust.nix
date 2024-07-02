{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pkgs.unstable.rust-analyzer
  ];
}
