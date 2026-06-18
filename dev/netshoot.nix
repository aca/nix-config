{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    tcpdump
    nmap
    openssl
    termshark
    tshark
    wireshark
  ];
}
