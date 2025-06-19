{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    dura
  ];
}
