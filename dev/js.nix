{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bun
    nodejs
    vscode-langservers-extracted
    biome
  ];
}
