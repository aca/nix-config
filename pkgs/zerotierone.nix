{
  config,
  pkgs,
  ...
}:
{
  services.zerotierone = {
    joinNetworks = [
      "68bea79acfa612d0"
    ];
  };
}
