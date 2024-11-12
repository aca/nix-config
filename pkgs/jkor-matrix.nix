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
  # services.caddy.enable = true;
  # services.caddy.virtualHosts."jkor-matrix.duckdns.org".extraConfig = ''
  #   reverse_proxy http://localhost:8008
  # '';
  # services.caddy.virtualHosts."jkor-matrix-ss.duckdns.org".extraConfig = ''
  #   reverse_proxy http://localhost:8009
  # '';

  # age.secrets.xxxxx.file = ./secrets/xxxxx.age;
  # age.secrets.xxxxx.mode = "777";
  # age.secrets.xxxxx.name = "xxxxx";

  services.matrix-synapse.enable = true;
  services.matrix-synapse.settings.server_name = "jkor-matrix.duckdns.org";
  services.matrix-synapse.settings.database.name = "sqlite3";
  services.matrix-synapse.settings.public_baseurl = "https://jkor-matrix.duckdns.org:443";
  services.matrix-synapse.settings.enable_registration = false;

  services.matrix-synapse.enableRegistrationScript = true;

  # age.secrets.xxx.file = ../secrets/home.services.matrix-synapse.extraConfigFiles.age;
  # age.secrets.xxx.mode = "777";

  age.secrets."home.services.matrix-synapse.extraConfigFiles.registration_shared_secret".file = ../secrets/home.services.matrix-synapse.extraConfigFiles.registration_shared_secret.age;
  age.secrets."home.services.matrix-synapse.extraConfigFiles.registration_shared_secret".mode = "777";
  services.matrix-synapse.extraConfigFiles = [
    # registration_shared_secret: $(openssl rand -hex 32)
    # config.age.secrets."home.services.matrix-synapse.extraConfigFiles.registration_shared_secret".path
    (pkgs.writeText "config" ''
      registration_shared_secret_path: ${config.age.secrets."home.services.matrix-synapse.extraConfigFiles.registration_shared_secret".path}
      serve_server_wellknown: true
      enable_registration_without_verification: true
      extra_well_known_client_content:
        "org.matrix.msc3575.proxy":
          "url": "https://jkor-matrix-ss.duckdns.org"
      rc_login:
        address:
          per_second: 0.15
          burst_count: 100
        account:
          per_second: 0.18
          burst_count: 100
        failed_attempts:
          per_second: 0.19
          burst_count: 100

    '')
  ];

  services.matrix-synapse.settings.listeners = [
    {
      bind_addresses = [
        "0.0.0.0"
      ];
      port = 8008;
      resources = [
        {
          compress = true;
          names = [
            "client"
          ];
        }
        {
          compress = false;
          names = [
            "federation"
          ];
        }
      ];
      tls = false;
      type = "http";
      x_forwarded = true;
    }
  ];

  # registration_shared_secret: generate with `openssl rand -hex 32`
  # services.matrix-synapse.extraConfigFiles = [
  #   (pkgs.writeText
  #     "matrix-synapse_extraConfigs"
  #     ''
  #       registration_shared_secret: ${builtins.readFile config.age.secrets.xxx.path}
  #       serve_server_wellknown: true
  #       enable_registration_without_verification: true
  #       extra_well_known_client_content:
  #         "org.matrix.msc3575.proxy":
  #           "url": "https://jkor-matrix-ss.duckdns.org"
  #     ''
  #     )
  # ];

  services.matrix-sliding-sync.enable = true;
  services.matrix-sliding-sync.settings.SYNCV3_SERVER = "https://jkor-matrix.duckdns.org:443";
  # secret file with
  #
  # SYNCV3_SECRET=$(openssl rand -hex 32)
  age.secrets."home.services.matrix-sliding-sync.environmentFile".file = ../secrets/home.services.matrix-sliding-sync.environmentFile.age;
  age.secrets."home.services.matrix-sliding-sync.environmentFile".mode = "777";
  services.matrix-sliding-sync.settings.SYNCV3_BINDADDR = "0.0.0.0:8009";
  services.matrix-sliding-sync.environmentFile = config.age.secrets."home.services.matrix-sliding-sync.environmentFile".path;
}
