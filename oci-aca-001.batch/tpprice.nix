{
  config,
  pkgs,
  ...
}:
{
  # systemd.services.price-check-tp = {
  #   serviceConfig.Type = "oneshot";
  #   onFailure = [ "ntfy-system-critical@price-check-tp.service" ];
  #   script = ''
  #     price=$(${pkgs.curl}/bin/curl -s 'https://openapi.lenovo.com/kr/ko/detail/price/batch/get?preSelect=1&mcode=21RKCTO1WWKR1&configId=&enteredCode=' --compressed -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Referer: https://www.lenovo.com/kr/ko/p/laptops/thinkpad/thinkpadx/thinkpad-x13-gen-6-13-inch-intel/21rkcto1wwkr1' -H 'Origin: https://www.lenovo.com' -H 'Connection: keep-alive' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H 'TE: trailers' | ${pkgs.jq}/bin/jq -r '.data["21RKCTO1WWKR1"][4]')
  #     echo "thinkpad price: $price"
  #     if [ "$price" -lt 1673083 ]; then
  #       echo "Price ($price) is less than 1673083!"
  #       exit 1
  #     fi
  #   '';
  # };
  #
  # systemd.timers.price-check-tp = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "10min";
  #     OnUnitActiveSec = "3h";
  #     Unit = "price-check-tp.service";
  #   };
  # };
}
