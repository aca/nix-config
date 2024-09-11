{
  config,
  pkgs,
  ...
}: {
  # https://github.com/dbohdan/structured-text-tools
  environment.systemPackages = with pkgs; [
    jq
    dasel
    # trdsql
    # q
    miller
    duckdb
  ];
}
