{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bear # https://github.com/rizsotto/Bear
    # tup
  ];
}
