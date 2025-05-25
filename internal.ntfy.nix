{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      # base-url = "https://jkor-ntfy.duckdns.org";
      listen-http = ":2556";
      behind-proxy = true;
      # allow sending notifications without authentication
      auth-default-access = "write-only";
      message-delay-limit = "100d";
      cache-duration = "300h";
      cache-startup-queries = ''
        pragma journal_mode = WAL;
        pragma synchronous = normal;
        pragma temp_store = memory;
        pragma busy_timeout = 15000;
        vacuum;
      '';
    };
  };
}
