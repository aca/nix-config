{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    jetbrains.datagrip
  ];
}
