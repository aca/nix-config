{
  config,
  pkgs,
  lib,
  ...
}: {
  # grafana localhost:3000
  # prometheus localhost:9090
  services.prometheus.enable = true;
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [
        {targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];}
      ];
    }
    {
      job_name = "smartctl";
      static_configs = [
        {targets = ["localhost:${toString config.services.prometheus.exporters.smartctl.port}"];}
      ];
    }
  ];


  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
  services.prometheus.exporters.node = {
    enable = true;
    port = 9000;
    enabledCollectors = ["systemd"];
    extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat"];
  };

  services.prometheus.exporters.smartctl = {
    enable = true;
    port = 9633;
    # maxInterval = "6h";
  };

  # services.loki.enable = true;

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        serve_from_sub_path = true;
      };
      security.admin_pasword = "admin";
    };
  };

  services.grafana.provision.datasources.settings = {
    apiVersion = 1;
    datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        url = "http://0.0.0.0:9090";
        orgId = 1;
      }
    ];
  };

  services.grafana.provision.dashboards.settings.providers = [
    {
      name = "node";
      options.path = ./grafana/dashboards/1860_rev37.json;
    }
  ];
}