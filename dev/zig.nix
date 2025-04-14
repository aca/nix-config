{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # zig
    # zigpkgs.default
  ];
}
