{
  services.zapret.enable = true;
  services.zapret.params = [
    # "--dpi-desync=disorder2"
    # "--dpi-desync=fake"
    # "--dpi-desync-ttl=1"
    # "--dpi-desync-autottl=1"

    "--dpi-desync=multidisorder"
    "--dpi-desync-split-pos=2"
  ];
}
