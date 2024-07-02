{
  config,
  pkgs,
  ...
}: {
  # https://github.com/dbohdan/structured-text-tools
  environment.systemPackages = with pkgs; [
    jq
    dasel
    # pkgs.unstable.trdsql
    # pkgs.unstable.q
    miller
    duckdb
  ];
}
