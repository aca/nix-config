{
  config,
  pkgs,
  ...
}: {
  # https://github.com/dbohdan/structured-text-tools
  environment.systemPackages = with pkgs; [
    quarto
    jq
    dasel
    # trdsql
    # q
    miller
    duckdb
  ];
}
