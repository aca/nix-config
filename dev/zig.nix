{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    zig
    zls
    # zigpkgs.default
  ];
}
