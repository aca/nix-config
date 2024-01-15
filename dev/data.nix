{
  config,
  pkgs,
  ...
}: {
  # https://github.com/dbohdan/structured-text-tools
  environment.systemPackages = with pkgs; [
    pkgs.unstable.jq
    pkgs.unstable.dasel
    # pkgs.unstable.trdsql
    # pkgs.unstable.q
    pkgs.unstable.miller
    pkgs.unstable.duckdb
  ];
}
