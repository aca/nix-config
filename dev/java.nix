{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jre_minimal

  ];
}
