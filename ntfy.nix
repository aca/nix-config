{
  config,
  inputs,
  pkgs,
  ...
}:
let
in
{
  systemd.services."ntfy-system-critical@" = {
    enable = true;
    # path = with pkgs [ jq curl ];
    scriptArgs = "%i";
    script = ''
      journalctl -u "$1" --since "$(systemctl show "$1" --property=ConditionTimestamp --value)" -n 10 -o json |\
        ${pkgs.jq}/bin/jq -r 'select(.SYSLOG_IDENTIFIER != "systemd") | .MESSAGE' |\
        ${pkgs.curl}/bin/curl -H "Priority: max" -H "Title: $HOSTNAME:$1" --data-binary @- "https://ntfy.xkor.stream/system-critical"
    '';
  };

  systemd.services."ntfy-system@" = {
    enable = true;
    scriptArgs = "%i";
    script = ''
      journalctl -u "$1" --since "$(systemctl show "$1" --property=ConditionTimestamp --value)" -n 10 -o json |\
        ${pkgs.jq}/bin/jq -r 'select(.SYSLOG_IDENTIFIER != "systemd") | .MESSAGE' |\
        ${pkgs.curl}/bin/curl -H "Priority: min" -H "Title: $HOSTNAME:$1" --data-binary @- "https://ntfy.xkor.stream/system"
    '';
  };
}
