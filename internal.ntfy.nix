{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}:
{
  options."internal.ntfy".baseUrl = lib.mkOption {
    type = lib.types.str;
    default = "https://ntfy.jkor.net";
    description = "Base URL for the ntfy service.";
  };
  options."internal.ntfy".port = lib.mkOption {
    type = lib.types.port;
    default = 3943;
    description = "Port for the ntfy service.";
  };

  # sudo ntfy user add --role admin root
  config = {
    services.ntfy-sh = {
      enable = true;
      settings = {
        # base-url = "https://jkor-ntfy.duckdns.org";
        base-url = "${config."internal.ntfy".baseUrl}";
        listen-http = ":${toString config."internal.ntfy".port}";
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
  };
}
