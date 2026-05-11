{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}:
{
  # services.temporal = {
  #   enable = true;
  #   package = pkgs.unstable.temporal;
  #   settings = {
  #     # Based on https://github.com/temporalio/temporal/blob/main/config/development-sqlite.yaml
  #     log = {
  #       stdout = true;
  #       level = "info";
  #     };
  #     services = {
  #       frontend = {
  #         rpc = {
  #           grpcPort = 7233;
  #           membershipPort = 6933;
  #           bindOnLocalHost = true;
  #           httpPort = 7243;
  #         };
  #       };
  #       matching = {
  #         rpc = {
  #           grpcPort = 7235;
  #           membershipPort = 6935;
  #           bindOnLocalHost = true;
  #         };
  #       };
  #       history = {
  #         rpc = {
  #           grpcPort = 7234;
  #           membershipPort = 6934;
  #           bindOnLocalHost = true;
  #         };
  #       };
  #       worker = {
  #         rpc = {
  #           grpcPort = 7239;
  #           membershipPort = 6939;
  #           bindOnLocalHost = true;
  #         };
  #       };
  #     };
  #
  #     persistence = {
  #       defaultStore = "sqlite-default";
  #       visibilityStore = "sqlite-visibility";
  #       numHistoryShards = 1;
  #       datastores = {
  #         sqlite-default = {
  #           sql = {
  #             user = "";
  #             password = "";
  #             pluginName = "sqlite";
  #             databaseName = "default";
  #             connectAddr = "localhost";
  #             connectProtocol = "tcp";
  #             connectAttributes = {
  #               mode = "memory";
  #               cache = "private";
  #             };
  #             maxConns = 1;
  #             maxIdleConns = 1;
  #             maxConnLifetime = "1h";
  #             tls = {
  #               enabled = false;
  #               caFile = "";
  #               certFile = "";
  #               keyFile = "";
  #               enableHostVerification = false;
  #               serverName = "";
  #             };
  #           };
  #         };
  #         sqlite-visibility = {
  #           sql = {
  #             user = "";
  #             password = "";
  #             pluginName = "sqlite";
  #             databaseName = "default";
  #             connectAddr = "localhost";
  #             connectProtocol = "tcp";
  #             connectAttributes = {
  #               mode = "memory";
  #               cache = "private";
  #             };
  #             maxConns = 1;
  #             maxIdleConns = 1;
  #             maxConnLifetime = "1h";
  #             tls = {
  #               enabled = false;
  #               caFile = "";
  #               certFile = "";
  #               keyFile = "";
  #               enableHostVerification = false;
  #               serverName = "";
  #             };
  #           };
  #         };
  #       };
  #     };
  #
  #     clusterMetadata = {
  #       enableGlobalNamespace = false;
  #       failoverVersionIncrement = 10;
  #       masterClusterName = "active";
  #       currentClusterName = "active";
  #       clusterInformation = {
  #         active = {
  #           enabled = true;
  #           initialFailoverVersion = 1;
  #           rpcName = "frontend";
  #           rpcAddress = "localhost:7233";
  #           httpAddress = "localhost:7243";
  #         };
  #       };
  #     };
  #
  #     dcRedirectionPolicy = {
  #       policy = "noop";
  #     };
  #
  #     archival = {
  #       history = {
  #         state = "enabled";
  #         enableRead = true;
  #         provider = {
  #           filestore = {
  #             fileMode = "0666";
  #             dirMode = "0766";
  #           };
  #           # gstorage = {
  #           #   credentialsPath = "/tmp/gcloud/keyfile.json";
  #           # };
  #         };
  #       };
  #       visibility = {
  #         state = "enabled";
  #         enableRead = true;
  #         provider = {
  #           filestore = {
  #             fileMode = "0666";
  #             dirMode = "0766";
  #           };
  #         };
  #       };
  #     };
  #
  #     namespaceDefaults = {
  #       archival = {
  #         history = {
  #           state = "enabled";
  #           URI = "file:///tmp/temporal_archival/development";
  #         };
  #         visibility = {
  #           state = "enabled";
  #           URI = "file:///tmp/temporal_vis_archival/development";
  #         };
  #       };
  #     };
  #   };
  # };
}
