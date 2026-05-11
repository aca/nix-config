{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    freecad
    openscad
    openscad-lsp
  ];
}
