{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nqp
    rakudo
  ];
}
