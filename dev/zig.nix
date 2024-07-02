{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # pkgs.unstable.zig
  ];
}
