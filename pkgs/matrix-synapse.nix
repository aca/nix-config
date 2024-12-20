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
  services.caddy.virtualHosts."jkor-matrix.duckdns.org".extraConfig = ''
    reverse_proxy http://localhost:8008
  '';
  services.caddy.virtualHosts."jkor-matrix-ss.duckdns.org".extraConfig = ''
    reverse_proxy http://localhost:8009
  '';

  services.matrix-synapse.enable = true;
  services.matrix-synapse.settings.server_name = "jkor-matrix.duckdns.org";
  # services.matrix-synapse.settings.database.name = "sqlite3";
  services.matrix-synapse.settings.public_baseurl = "https://jkor-matrix.duckdns.org:443";
  services.matrix-synapse.settings.enable_registration = false;

  services.matrix-synapse.enableRegistrationScript = true;
  services.matrix-synapse.extraConfigFiles = [
    # registration_shared_secret: generate with `openssl rand -hex 32`
    (pkgs.writeText
      "matrix-synapse_extraConfigs"
      ''
        serve_server_wellknown: true
        registration_shared_secret: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
        enable_registration_without_verification: true
        extra_well_known_client_content:
          "org.matrix.msc3575.proxy":
            "url": "https://jkor-matrix-ss.duckdns.org"
      '')
  ];

  services.matrix-synapse.settings.listeners = [
    {
      bind_addresses = ["127.0.0.1"];
      port = 8008;
      resources = [
        {
          compress = false;
          names = ["client" "federation"];
        }
      ];
      tls = false;
      type = "http";
      x_forwarded = true;
    }
  ];

  services.matrix-sliding-sync.enable = true;
  services.matrix-sliding-sync.settings.SYNCV3_SERVER = "https://jkor-matrix.duckdns.org:443";
  # secret file with
  #
  # SYNCV3_SECRET=$(openssl rand -hex 32)
  #
  services.matrix-sliding-sync.environmentFile = config.age.secrets."home.services.matrix-sliding-sync.environmentFile".path;
}
