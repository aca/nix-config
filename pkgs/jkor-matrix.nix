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

  # services.caddy.virtualHosts."mx-synapse-ss.duckdns.org".extraConfig = ''
  #   reverse_proxy http://localhost:8009
  # '';

  # age.secrets.xxxxx.file = ./secrets/xxxxx.age;
  # age.secrets.xxxxx.mode = "777";
  # age.secrets.xxxxx.name = "xxxxx";

  # sudo -u postgres psql << EOF
  # CREATE ROLE "matrix-synapse";
  # CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
  #   TEMPLATE template0
  #   LC_COLLATE = "C"
  #   LC_CTYPE = "C";
  # ALTER ROLE "matrix-synapse" WITH LOGIN;
  # EOF

  services.postgresql = {
    enable = true;
    # ensureDatabases = ["asset"];
    enableTCPIP = true;
    # authentication = pkgs.lib.mkOverride 10 ''
    #   local all all              trust
    #   host  all all 127.0.0.1/32 trust
    #   host  all all ::1/128      trust
    #   host  all all 100.0.0.0/8 trust
    # '';

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
    ensureUsers = [
      {name = "rok";}
    ];
    settings.port = 5432;
  };

  # services.postgresql.initialScript = pkgs.writeText "Initial-PostgreSQL-Database" ''
  #   CREATE ROLE "matrix-synapse";
  #   CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
  #     TEMPLATE template0
  #     LC_COLLATE = "C"
  #     LC_CTYPE = "C";
  # '';
  services.matrix-synapse.enable = true;
  services.matrix-synapse.settings.server_name = "mx-synapse.duckdns.org";
  services.matrix-synapse.settings.database.name = "psycopg2";
  services.matrix-synapse.settings.public_baseurl = "https://mx-synapse.duckdns.org:443";
  services.matrix-synapse.settings.enable_registration = false;
  services.matrix-synapse.enableRegistrationScript = true;

  # bash -c 'echo "registration_shared_secret: $(openssl rand -hex 32)"'
  age.secrets."mx-synapse.extraConfigFiles.registration_shared_secret" = {
    file = ../secrets/mx-synapse.extraConfigFiles.registration_shared_secret.age;
    mode = "444";
  };

  services.matrix-synapse.extraConfigFiles = [
    config.age.secrets."mx-synapse.extraConfigFiles.registration_shared_secret".path
    # registration_shared_secret_path: ${
    # }
    # (pkgs.writeText "config" ''
    #   serve_server_wellknown: true
    #   enable_registration_without_verification: true
    #   extra_well_known_client_content:
    #     "org.matrix.msc3575.proxy":
    #       "url": "https://mx-synapse-ss.duckdns.org"
    #   rc_login:
    #     address:
    #       per_second: 0.15
    #       burst_count: 100
    #     account:
    #       per_second: 0.18
    #       burst_count: 100
    #     failed_attempts:
    #       per_second: 0.19
    #       burst_count: 100
    # '')
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

  # services.matrix-sliding-sync.enable = true;
  # services.matrix-sliding-sync.settings.SYNCV3_SERVER = "https://mx-synapse.duckdns.org:443";
  # secret file with
  #
  # SYNCV3_SECRET=$(openssl rand -hex 32)
  # age.secrets."home.services.matrix-sliding-sync.environmentFile".file =
  #   ../secrets/home.services.matrix-sliding-sync.environmentFile.age;
  # age.secrets."home.services.matrix-sliding-sync.environmentFile".mode = "777";
}
