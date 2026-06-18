{
  config,
  pkgs,
  ...
}:
{
  # systemd.services.autoupdate-claude = {
  #   serviceConfig.User = "rok";
  #   serviceConfig.Restart = "always";
  #   serviceConfig.RestartSec = "1h";
  #   wantedBy = [ "network.target" ];
  #   path = [
  #     "/run/current-system/sw"
  #     # with this config, /home/rok/bin will be in $PATH, required by pnpm to work
  #     "/home/rok"
  #   ];
  #   script = ''
  #     pnpm config set global-bin-dir /home/rok/bin
  #     pnpm install -g @anthropic-ai/claude-code@latest
  #   '';
  # };
  #
  # systemd.timers.autoupdate-claude = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "daily";
  #     Unit = "autoupdate-claude";
  #   };
  # };
}
