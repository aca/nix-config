{
  config,
  lib,
  pkgs,
  ...
}:
let
  _default = {
    enable = true;
    startLimitBurst = 0;
    startLimitIntervalSec = 2;
    serviceConfig.User = "rok";
    # serviceConfig.StartLimitIntervalSec = "5";
    serviceConfig.EnvironmentFile = "/run/agenix/env";
    serviceConfig.Environment = [ "LOG_FORMAT=json" ];
    serviceConfig.ExecSearchPath = "/run/current-system/sw/bin";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "5s";

    wantedBy = [ "network-online.target" ];
    path = [ "/run/current-system/sw" ];
  };

  bot = lib.recursiveUpdate _default {
    serviceConfig.WorkingDirectory = "/home/rok/src/git.internal/bot";
    # serviceConfig.ExecStart = "go run ./cmd/%N";
    # wantedBy = [ "network.target" ];
    requires = [
      "git-sync.service"
      "postgresql.service"
    ];

    after = [
      "sys-subsystem-net-devices-tailscale0.device" # https://www.reddit.com/r/Tailscale/comments/ubk9mo/systemd_how_do_get_something_to_run_if_tailscale/
      "tailscaled.service"
      "git-sync.service" # define it in requires,after to wait for it to finish
      "postgresql.service"
    ];
  };
in
{
  systemd.services."tb-one-usdc" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tb-one-usdc KRW-USDC";
  };

  systemd.services."tb-one-usdt" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tb-one-usdt KRW-USDT";
  };

  systemd.services."tb-one-usd1" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tb-one-usd1 KRW-USD1";
  };

  systemd.services."tb-one-usde" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tb-one-usde KRW-USDE";
  };

  systemd.services."tb-one-rlusd" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tb-one-rlusd KRW-RLUSD";
  };

  # systemd.services."tb-one-xaut" = lib.recursiveUpdate bot {
  #   serviceConfig.ExecStart = "go run ./cmd/tb-one-xaut KRW-XAUT";
  # };

  systemd.services."ts-main" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/ts-main";
  };

  systemd.services."ts-main-kr" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/ts-main-kr";
  };

  systemd.services."tsdata-fx-xe" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tsdata-fx-xe";
  };

  systemd.services."tsdata-bitget" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tsdata-bitget";
  };

  systemd.services."tsdata-binance" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tsdata-binance";
  };

  systemd.services."tsdata-coinone-balance" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tsdata-coinone-balance";
  };

  systemd.services."tsdata-coinone" = lib.recursiveUpdate bot {
    serviceConfig.ExecStart = "go run ./cmd/tsdata-coinone";
  };

  # systemd.services."toki" = lib.recursiveUpdate bot {
  #   serviceConfig.ExecStart = "go run ./cmd/toki";
  # };

  systemd.timers."git-sync" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/5";
      Unit = "git-sync.service";
    };
  };

  # systemd.services."xpra-chromium" = {
  #   enable = true;
  #   serviceConfig = {
  #     User = "rok";
  #   };
  #   script = "${pkgs.xpra}/bin/xpra start :100 --start=/run/current-system/sw/bin/chromium --daemon=no";
  #   wantedBy = [ "network-online.target" ];
  # };

  services.caddy.virtualHosts."ping.xkor.stream".extraConfig = ''
    reverse_proxy http://localhost:8119
  '';

  systemd.services."ping" = lib.recursiveUpdate _default {
    serviceConfig.WorkingDirectory = "/home/rok/src/git.internal/oci-aca-001/ping";
    script = "git pull --rebase && go run main.go";
  };

  # systemd.services."tb-one-usde" = bot // {
  #   serviceConfig = bot.serviceConfig // {
  #     ExecStart = lib.mkForce "go run ./cmd/tb-one-usde KRW-USDE";
  #   };
  # };

  # systemd.services."one-chase-usdt" = bot;

  # systemd.services."tb-one-usde" = bot;
  # systemd.services."tb-up-usdt" = bot;
  # systemd.services."tb-up-usdtusdc" = bot;

  # systemd.services."asset-exporter" = bot;
  # systemd.services."nop" = bot;
  # systemd.services."tb-one-cancel-usde" = bot;

  # systemd.services."test-systemd" = {
  #   serviceConfig.User = "rok";
  #   # serviceConfig.Restart = "never";
  #   serviceConfig.RestartSec = "3s";
  #   restartIfChanged = true;
  #   reloadIfChanged = true;
  #   serviceConfig.WorkingDirectory = "/home/rok/src/git.internal/bot";
  #   wantedBy = [ "default.target" ];
  #   path = [ "/run/current-system/sw" ];
  #   preStart = "git pull --rebase";
  #   script = "go run ./cmd/test-systemd";
  # };

  systemd.services."log-test" = bot // {
    serviceConfig = bot.serviceConfig // {
      ExecStart = lib.mkForce "go run ./cmd/log-test";
    };
  };

  systemd.services."git-sync" = {
    enable = true;
    startLimitIntervalSec = 0;
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      User = "rok";
      WorkingDirectory = "/home/rok/src/git.internal/bot";
      Restart = "no";
    };
    script = ''
      timeout 10s ping -c 1 home || exit 0
      /run/current-system/sw/bin/git pull --rebase && /run/current-system/sw/bin/go mod download
    '';
    wantedBy = [ "network-online.target" ];
  };

  # systemd.services."socat-9222" = {
  #   enable = true;
  #   serviceConfig = {
  #     ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:9222,bind=100.97.173.112,fork TCP:127.0.0.1:9222";
  #   };
  #   wantedBy = [ "network-online.target" ];
  # };

  systemd.services."price-monitor" = {
    enable = true;
    serviceConfig.User = "rok";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "5s";
    # serviceConfig.StartLimitIntervalSec = "5";
    serviceConfig.WorkingDirectory = "/home/rok/src/git.internal/bot/cmd/price-monitor";
    serviceConfig.EnvironmentFile = "/run/agenix/env";
    serviceConfig.Environment = [ "LOG_FORMAT=json" ];
    serviceConfig.ExecSearchPath = "/run/current-system/sw/bin";
    serviceConfig.ExecStart = "go run main.go";
    wantedBy = [ "network-online.target" ];
    path = [ "/run/current-system/sw" ];
    requires = [
      "git-sync.service"
    ];
    # https://www.reddit.com/r/Tailscale/comments/ubk9mo/systemd_how_do_get_something_to_run_if_tailscale/
    after = [
      "sys-subsystem-net-devices-tailscale0.device"
      "tailscaled.service"
    ];
    # preStart = "sudo systemctl start git-sync";
  };

  systemd.services."claude-ocr" = {
    enable = true;
    serviceConfig.User = "rok";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "5s";
    # serviceConfig.StartLimitIntervalSec = "5";
    serviceConfig.WorkingDirectory = "/home/rok/src/github.com/aca/claude-ocr";
    serviceConfig.EnvironmentFile = "/run/agenix/env";
    serviceConfig.ExecSearchPath = "/run/current-system/sw/bin";
    serviceConfig.ExecStart = "bun run solve.ts --port 4444";
  };
}
