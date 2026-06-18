{
  config,
  pkgs,
  lib,
  ...
}:
let
  # kime XIM 서버를 띄우고 chromium을 실행하는 래퍼.
  # chromium은 GTK 앱이므로 GTK 내장 xim immodule을 통해 kime에 붙는다
  # (별도 immodule 캐시 생성이 필요 없어 Nix 환경에서 가장 안정적).
  chromium-ime = pkgs.writeShellScript "chromium-kime" ''
    export GTK_IM_MODULE=xim
    export QT_IM_MODULE=xim
    export XMODIFIERS=@im=kime

    ${pkgs.kime}/bin/kime-xim &
    sleep 1

    exec /run/current-system/sw/bin/chromium
  '';
in
{
  services.xserver.enable = true;
  systemd.services."xpra-chromium" = {
    enable = true;
    serviceConfig = {
      User = "rok";
    };
    script = "${pkgs.xpra}/bin/xpra start :1000 --start=${chromium-ime} --daemon=no";
    wantedBy = [ "network-online.target" ];
  };
}
