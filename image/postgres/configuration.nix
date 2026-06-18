{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.procps ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    extensions = ps: [ ps.pgvector ps.pg_rational ps.timescaledb ];
    settings = {
      shared_preload_libraries = "timescaledb";
      listen_addresses = "*";
    };
    enableTCPIP = true;
    authentication = ''
      host all all 0.0.0.0/0 trust
    '';
  };

  nixpkgs.config.allowUnfree = true;
  networking.firewall.enable = false;
  system.stateVersion = "26.05";
}
