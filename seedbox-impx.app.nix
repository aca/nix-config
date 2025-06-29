{
  config,
  pkgs,
  ...
}: {

  # systemd.services."adjust-order" = {
  #   serviceConfig.User = "rok";
  #   serviceConfig.Restart = "always";
  #   serviceConfig.RestartSec = "3s";
  #   serviceConfig.WorkingDirectory = "/home/rok/src/github.com/investing-kr/bot/cmd/adjust-order";
  #   wantedBy = ["network.target"];
  #   path = ["/run/current-system/sw"];
  #   preStart = "git pull --rebase";
  #   script = "source /run/agenix/env; go run .";
  # };

  systemd.services."trader-bt" = {
    serviceConfig.User = "rok";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "1s";
    serviceConfig.WorkingDirectory = "/home/rok/src/github.com/investing-kr/bot/cmd/trader-bt";
    wantedBy = ["network.target"];
    path = ["/run/current-system/sw"];
    # preStart = "git pull --rebase";
    script = "source /run/agenix/env.home; go run .";
  };

  systemd.services."trader-one" = {
    serviceConfig.User = "rok";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "1s";
    serviceConfig.WorkingDirectory = "/home/rok/src/github.com/investing-kr/bot/cmd/trader-one";
    wantedBy = ["network.target"];
    path = ["/run/current-system/sw"];
    # preStart = "git pull --rebase";
    script = "source /run/agenix/env.home; go run .";
  };

  systemd.services."trader-up" = {
    serviceConfig.User = "rok";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "1s";
    serviceConfig.WorkingDirectory = "/home/rok/src/github.com/investing-kr/bot/cmd/trader-up";
    wantedBy = ["network.target"];
    path = ["/run/current-system/sw"];
    # preStart = "git pull --rebase";
    script = "source /run/agenix/env.home; go run .";
  };

  systemd.services."trader-buy-cancel" = {
    serviceConfig.User = "rok";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = "1s";
    serviceConfig.WorkingDirectory = "/home/rok/src/github.com/investing-kr/bot/cmd/trader-buy-cancel";
    wantedBy = ["network.target"];
    path = ["/run/current-system/sw"];
    # preStart = "git pull --rebase";
    script = "source /run/agenix/env.home; go run .";
  };
}
