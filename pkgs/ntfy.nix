# Create user manually with
#
#   sudo matrix-synapse-register_new_matrix_user
#
{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}: {
  # use caddy as a reverse proxy, serve synapse, sliding-sync
  services.caddy.enable = true;
  services.caddy.virtualHosts."mx-synapse.duckdns.org".extraConfig = ''
    reverse_proxy http://localhost:8008
  '';

  # services.ntfy-sh = {
  #   enable = true;
  #   settings = {
  #     base-url = "https://jkor-ntfy.duckdns.org";
  #     listen-http = ":2556";
  #     behind-proxy = true;
  #     # allow sending notifications without authentication
  #     auth-default-access = "write-only";
  #     message-delay-limit = "100d";
  #     cache-duration = "144h";
  #     cache-startup-queries = ''
  #       pragma journal_mode = WAL;
  #       pragma synchronous = normal;
  #       pragma temp_store = memory;
  #       pragma busy_timeout = 15000;
  #       vacuum;
  #     '';
  #   };
  # };
}
