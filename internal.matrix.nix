# Create user manually with
#
#   sudo matrix-synapse-register_new_matrix_user
#
{
  config,
  pkgs,
  options,
  inputs,
  secrets,
  lib,
  ...
}:
{
 
  # use caddy as a reverse proxy, serve synapse, sliding-sync
  services.caddy.enable = true;

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

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
    ensureUsers = [
      { name = "rok"; }
    ];
    settings.port = 5432;

    initialScript = pkgs.writeText "init" ''
      CREATE ROLE "matrix-synapse";
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
      ALTER ROLE "matrix-synapse" WITH LOGIN;
    '';
  };

  services.matrix-synapse.enable = true;
  services.matrix-synapse.settings.database.name = "psycopg2";
  # services.matrix-synapse.settings.server_name = "matrix.${secrets.INTERNAL_BASEURL}";
  # services.matrix-synapse.settings.public_baseurl = "https://matrix.${secrets.INTERNAL_BASEURL}";
  services.matrix-synapse.settings.enable_registration = false;
  services.matrix-synapse.enableRegistrationScript = true;

  # # bash -c 'echo "registration_shared_secret: $(openssl rand -hex 32)"'
  # services.matrix-synapse.extraConfigFiles = [
  #   config.age.secrets."services.matrix-synapse.extraConfigFiles.registration_shared_secret".path
  # ];

  services.matrix-synapse.settings.listeners = [
    {
      bind_addresses = [
        "0.0.0.0"
      ];
      port = 8448;
      resources = [
        {
          compress = true;
          names = [
            "client"
          ];
        }
        {
          compress = true;
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
}
