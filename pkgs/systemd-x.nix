{
  config,
  pkgs,
  ...
}: {
  # systemd.timers."errtest" = {
  #   wantedBy = ["timers.target"];
  #   enable = true;
  #   timerConfig = {
  #     # OnBootSec = "10m";
  #     OnUnitActiveSec = "5m";
  #     Unit = "errtest.service";
  #   };
  # };

  systemd.services."test_errtest" = {
    enable = true;
    # postStop = ''
    # echo service_result: $SERVICE_RESULT; echo exit_code: $EXIT_CODE echo exit_status $EXIT_STATUS;
    # '';
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };
    script = with pkgs; ''
      rand=$(( RANDOM % 3 + 1 ))
      echo "started"
      if [[ $rand -eq 1 ]]; then exit 1; else exit 0; fi
    '';
  };
}
