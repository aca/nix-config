# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  networking.firewall.enable = false;
  networking.hostName = "txxx-orb";

#   environment.systemPackages = [
# ];

  imports = [
    # Include the default lxd configuration.
    "${modulesPath}/virtualisation/lxc-container.nix"
    # Include the OrbStack-specific configuration.
    ./txxx-orb.orbstack.nix

    ./pkgs/tmux/tmux.nix
    ./pkgs/i3.nix

    ./env.nix
    # ./hardware/txxx-nix.nix
    # ./nixos/fonts.nix

    ./dev/nix.nix
    ./dev/c.nix
    ./dev/rust.nix
    ./dev/default.nix
    ./dev/zig.nix
    ./dev/js.nix
    ./dev/data.nix
    ./dev/linux.nix
    ./dev/go.nix
    ./dev/container.nix
    ./dev/python.nix
    ./dev/lua.nix
    ./dev/go.nix
    # ./dev/neovim_conf.nix
  ];



  environment.systemPackages = with pkgs; [
    elvish
    tshark
    termshark

    (pkgs.writeShellScriptBin "pbcopy" ''
      /opt/orbstack-guest/bin/pbcopy
    '')
    (pkgs.writeShellScriptBin "ci" ''
      /opt/orbstack-guest/bin/pbcopy
    '')
    (pkgs.writeShellScriptBin "pbpaste" ''
      /opt/orbstack-guest/bin/pbpaste
    '')
    (pkgs.writeShellScriptBin "co" ''
      /opt/orbstack-guest/bin/pbpaste
    '')
  ];

  environment.sessionVariables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.oracle-instantclient ];
  };

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    # "net.ipv4.conf.all.forwarding" = true;
    # "net.ipv4.ip_forward" = 1;
    # "net.ipv6.conf.all.forwarding" = true;

    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--ssh"
    "--accept-risk=all"
    "--advertise-exit-node=true"
    ];
  services.tailscale.extraDaemonFlags = [
    # "--ssh"
    "--socks5-server=0.0.0.0:1080"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rok = {
    isNormalUser = true;
    description = "rok";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "wireshark"
    ];
    packages = with pkgs; [ ];
  };

  users.users.rok.openssh.authorizedKeys.keys = [
    (import ./keys.nix).root
    (import ./keys.nix).home
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10''
  ];

  environment.variables.ZK_ROOT = "/home/rok/src/git.internal/zk";
  environment.variables.ZK_LOCAL_ROOT = "/home/rok/src/git.internal/zk/txxx";

  # services.dnsmasq = {
  #   enable = true;
  #
  #   # Forward *everything* to these upstreams
  #
  #   settings = {
  #     cache-size = 10000;
  #     clear-on-reload = true;
  #     min-cache-ttl = 3600;
  #     log-queries = true;
  #     log-dhcp = true;
  #     server = [
  #       "8.8.8.8"
  #     ];
  #   };
  # };

  users.users."kyungrok.chung" = {
    uid = 1095052480;
    extraGroups = [
      "wheel"
      "orbstack"
    ];

    # simulate isNormalUser, but with an arbitrary UID
    isSystemUser = true;
    group = "users";
    createHome = true;
    home = "/home/kyungrok.chung";
    homeMode = "700";
    useDefaultShell = true;
  };

  security.sudo.wheelNeedsPassword = false;

  # This being `true` leads to a few nasty bugs, change at your own risk!
  users.mutableUsers = false;

  time.timeZone = "Asia/Seoul";

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # Extra certificates from OrbStack.
  security.pki.certificates = [
    ''
            -----BEGIN CERTIFICATE-----
      MIIDvTCCAqWgAwIBAgIFAO79hJcwDQYJKoZIhvcNAQELBQAwPTE7MDkGA1UEAxMy
      VG9zcyBTZWN1cml0aWVzIEpTUyBCdWlsdC1pbiBDZXJ0aWZpY2F0ZSBBdXRob3Jp
      dHkwHhcNMjIwMzA3MDE0ODU3WhcNMzIwMzA4MDE0ODU3WjA9MTswOQYDVQQDEzJU
      b3NzIFNlY3VyaXRpZXMgSlNTIEJ1aWx0LWluIENlcnRpZmljYXRlIEF1dGhvcml0
      eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANIJFE3V0y3U7gnSxxJb
      m0+AuXAISZmH+6vOXobwWa07e88neIMhcTCRszzDEBGR8OI/9RHYxP0AsvUx9D+l
      YNrN8WsJiRayjsgB22OJWCLp0J8tt4JRmWkQjV2KNFm2L0LhCS3A1pXXiKO2m2GE
      snBban3hlVCI+Lx+oYiXb0tWaK9qC90+q3y76Fa1RMaklcOOufobYrELJxhW/AyK
      0MLbxZxt+3dEdGTxzTmAgNNKQlOhizopfW4U/072irexgbCNO6QroBUdHuQI8+1y
      1PFAiyKNZkLwrjcBO6BnL+knaGaZrYjVg9jLhK7C1h0yWj7eCBq3jAs3JJ5scTjk
      47UCAwEAAaOBwzCBwDAdBgNVHQ4EFgQUttNUDoPnzHNvC1hKXQOkG26uljUwEwYD
      VR0lBAwwCgYIKwYBBQUHAwEwDgYDVR0PAQH/BAQDAgGmMA8GA1UdEwEB/wQFMAMB
      Af8wSAYDVR0fBEEwPzA9oDugOYY3aHR0cHM6Ly90b3Nzc2VjdXJpdGllcy5qYW1m
      Y2xvdWQuY29tLy9DQS9KQU1GQ1JMU2VydmxldDAfBgNVHSMEGDAWgBS201QOg+fM
      c28LWEpdA6Qbbq6WNTANBgkqhkiG9w0BAQsFAAOCAQEA0Bs2wgvranqBEgP16E9U
      AY1km2QQzOyQOOQFsite+62gV5QbjcFAuSrFuAZ/tUWiZiP4Siy+ZRwHzajzNx3/
      1xJ8UwKBcB5V0dwae0cbipa6ZY57eWZC/RlssLpUnyWGhTLrre+0eyOkVkmolKdJ
      ctmV2UVHmnAnYyBbGYHh1DnazLTHBgVJ09W6Ld5XEV91eacGbKhGrTAEXqnXEv65
      aqZU8xnyyFaTlcN17GYaZS1G/6m/Jjjs1JmMcb6+48I0pOSv8zWWG4380IfQ9o0S
      6Qf+7qOPb4pOABvxwrgzUjBVVysoz5Z3dXMZrR6MlKgqzn7Gp9hNt2KKr92hzyxc
      UQ==
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIID1jCCAr6gAwIBAgIUBz8Qc55zauB6TgBFqEUhbc4OEHMwDQYJKoZIhvcNAQEL
      BQAwgZoxCzAJBgNVBAYTAktSMQ4wDAYDVQQIDAVTZW91bDEOMAwGA1UEBwwFU2Vv
      dWwxEzARBgNVBAoMCnRvc3NpbnZlc3QxETAPBgNVBAsMCFNlY3VyaXR5MRswGQYD
      VQQDDBJ0b3NzaW52ZXN0X2JsdWVtYXgxJjAkBgkqhkiG9w0BCQEWF3NlY3VyaXR5
      QHRvc3NpbnZlc3QuY29tMCAXDTIxMDMwOTAzNTIzN1oYDzIwNTEwMzAyMDM1MjM3
      WjCBmjELMAkGA1UEBhMCS1IxDjAMBgNVBAgMBVNlb3VsMQ4wDAYDVQQHDAVTZW91
      bDETMBEGA1UECgwKdG9zc2ludmVzdDERMA8GA1UECwwIU2VjdXJpdHkxGzAZBgNV
      BAMMEnRvc3NpbnZlc3RfYmx1ZW1heDEmMCQGCSqGSIb3DQEJARYXc2VjdXJpdHlA
      dG9zc2ludmVzdC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDe
      BGM+RHU9Iq3mOdiihknjSAZFkgVlGicbRmFWjXn3r7+RtqKXva/p0nekrp6NowqF
      o49KQkfmENd78ivnL/n8r1hRs18oceZpvRtb333bczdEJw+6QyDmrfjBa5uKq/75
      oWlElcrDMO3XmdeqrXOcXE0/IRVgmZD0s7c/zfmK8Ccw8p0uvMsHk141OEpKWKs0
      YJFly1zyVj1FWk5Q88by4IiezQqDQTfGMuJlh24BmmqRvPvv6ZinoYTpiyVnR/BC
      S/Fcesy3yu2kcrQxJv2tu06a7tbS9lJlzIM9V2LZAy4Wuek+da2lqwzEiyJGirFW
      UBFqQigPUrEmF2lAvLZZAgMBAAGjEDAOMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcN
      AQELBQADggEBAENcFBHEYvVGRGG/V4Yg0toPY/qqQKNEW2PcntcpP9wUB5zpAwB2
      yJyTHXTZAqKWTRRFSw54AgVfbaH+k+AZDrj7WxvhuBh5Y9Twa928S2kAyioRcu3v
      hLgkYmqFUMInjGc0NN/SzPS7HPZl2d1jASab0CVItUcb5A0WM/86plmiPhGMxE8/
      20Sxn3ObGxdo2F1413270/Ms6v3ZYy01qnzXp89Jgjpnl0Ay9K+Tk98ODc62aFaj
      xGHWC2AxxUmuZbhljmwqLGRzTiEI6uHtqdS4tSfZAHSLzgn8kq62hwKAlEOLU+O7
      38+lgrBJTAFJaYBtzWIc3sBvuGlpCMQAKgc=
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIID6jCCAtKgAwIBAgIIFCzbtDx3Zf8wDQYJKoZIhvcNAQELBQAwejELMAkGA1UE
      BhMCSUUxDTALBgNVBAcMBENvcmsxFzAVBgNVBAoMDkZvcmNlcG9pbnQgTExDMR8w
      HQYDVQQLDBZGb3JjZXBvaW50IEVuZ2luZWVyaW5nMSIwIAYDVQQDDBlGb3JjZXBv
      aW50IEYxRSBOUCBSb290IENBMB4XDTI0MTExMjA4MzUxMFoXDTI3MDIxNDA4MzUx
      MFowejELMAkGA1UEBhMCSUUxDTALBgNVBAcMBENvcmsxFzAVBgNVBAoMDkZvcmNl
      cG9pbnQgTExDMR8wHQYDVQQLDBZGb3JjZXBvaW50IEVuZ2luZWVyaW5nMSIwIAYD
      VQQDDBlGb3JjZXBvaW50IEYxRSBOUCBSb290IENBMIIBIjANBgkqhkiG9w0BAQEF
      AAOCAQ8AMIIBCgKCAQEAtPrg4Ed47+nhZf+27sffkzuEZHIc3TMhK0stN1MpuVQ+
      RGyZgHD19AHPNqdn3UYphER8/J6JWTlDQzwNVMHYLZLDj7Phafysethv9wQxTqV/
      fypsSTPYVn2/56K5s1AhT7xmTZdyw829qq6WvXJaGpqZJfabgyBHzd6JAOIUjEBB
      1Oy16/ANhx8+tKpEB6BaqGt17io3QDEwhfB7YLyxvRLtANsKx4h4mzorn93jUX86
      BQ9SiqFzSHsMARC/PQ3A3yWK0tO/3MOgOcOp5l2qp9ycIJgp9v2YMuBb8Tl5aGVN
      AmcmWjETllggtFkkGIzdaQvQ4by57zx+PrlRRQgbgQIDAQABo3QwcjAPBgNVHRMB
      Af8EBTADAQH/MA4GA1UdDwEB/wQEAwICBDAdBgNVHQ4EFgQUYtpOlRPyWr8xBvNy
      VqQkiKE6auEwHwYDVR0jBBgwFoAUYtpOlRPyWr8xBvNyVqQkiKE6auEwDwYKKwYB
      BAGC8008AQQBMTANBgkqhkiG9w0BAQsFAAOCAQEAQ3Pp76c1teSjPrwRZAS5F1v4
      jOHUph1kFgTgpovUGoy5HAMvbym9Oe3oybkDhw7i0uE641QpNUawrvvA4v9fZN1M
      h3mc0jtzl66pKnNf90afJupJTvG6aBri9W8RvtoIIo95ucn3aUlxi/TecpnrAjTl
      pNUAtSAI88ZDJj4hLLh0sT+gNOzNHTApilhAgrB+OcAFQwfofoRBKNv47Ikihoy3
      h5thbvsXZqC6+9hNkN1uzj+T+l5l7QQe+0MVKq/wDF5bi5hN5+5A/ht1LAvgbagr
      cSkpjP40nriYryWZiIobxwpD4xj6gwmd48sy3Aar/qM4Lu7XHuPOW6TQjDW6qw==
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIIFFjCCA/6gAwIBAgIUJNySDckZLmwvDauqRVYVSSyrsykwDQYJKoZIhvcNAQEL
      BQAwgakxCzAJBgNVBAYTAktSMQ4wDAYDVQQIDAVTb3V0aDERMA8GA1UECwwIMTY0
      NDhjYWUxEzARBgNVBAcMCkdlbmlhbiBOQUMxFjAUBgNVBAoMDUdFTklBTlMsIElO
      Qy4xHzAdBgkqhkiG9w0BCQEWEGhlbHBAZ2VuaWFucy5jb20xKTAnBgNVBAMMIEdl
      bmlhbiBOQUMgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTI0MTAzMDExMjg0MVoX
      DTI1MTAzMDExMjg0MVowgakxCzAJBgNVBAYTAktSMQ4wDAYDVQQIDAVTb3V0aDER
      MA8GA1UECwwIMTY0NDhjYWUxEzARBgNVBAcMCkdlbmlhbiBOQUMxFjAUBgNVBAoM
      DUdFTklBTlMsIElOQy4xHzAdBgkqhkiG9w0BCQEWEGhlbHBAZ2VuaWFucy5jb20x
      KTAnBgNVBAMMIEdlbmlhbiBOQUMgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBIjAN
      BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx5OgLOfusOV9+m7YYzLdtKYMJhfM
      G0ZhrxArRJUenGXOwhc23vkh54EUyYhH2uhhsYeuYz7njmdl6K15fvvpRlOEG0jI
      UecJu0bswTYDjzcMH1Lz5+sUqYi+a1mCQ03Va22FQkZYhLbyMqqrMGGJyO6+A/0C
      ynimAwxPvPnOBlOOKJ4KwqwHPxyWCFwvqwy5xw5AlWKl+5twt2pQE+/TU2an3X+D
      m9dv2gV8OY/uMcq49+BOm9gQwqJOSUqNgj/9Tjv6Jti2+Pc6unyd1IphWlgXmhId
      guNSCEHowFtTv42qIzKWh9Gl64xg4G6GnYo6Z+h88eDY1fXVrX2V0LCxxwIDAQAB
      o4IBMjCCAS4wHQYDVR0OBBYEFO5CPeZfyDSZ/+tUcJsOeEbaRfFdMIHpBgNVHSME
      geEwgd6AFO5CPeZfyDSZ/+tUcJsOeEbaRfFdoYGvpIGsMIGpMQswCQYDVQQGEwJL
      UjEOMAwGA1UECAwFU291dGgxETAPBgNVBAsMCDE2NDQ4Y2FlMRMwEQYDVQQHDApH
      ZW5pYW4gTkFDMRYwFAYDVQQKDA1HRU5JQU5TLCBJTkMuMR8wHQYJKoZIhvcNAQkB
      FhBoZWxwQGdlbmlhbnMuY29tMSkwJwYDVQQDDCBHZW5pYW4gTkFDIENlcnRpZmlj
      YXRlIEF1dGhvcml0eYIUJNySDckZLmwvDauqRVYVSSyrsykwDAYDVR0TBAUwAwEB
      /zATBgNVHSUEDDAKBggrBgEFBQcDATANBgkqhkiG9w0BAQsFAAOCAQEAb2gYyTBl
      z46E6kPjWaRbDmk4pu7UrbVawslKsTm9LBBbJcTH9Tmj9ethUE8kKnnzY/QVrom4
      XZqFsxDX7wOcrEZAlOjVpVNo9Q2vRRLljqIGt8m5xwRh0MItXEBC6/F+fwswnkFt
      O3c2ghHhtec0Mdje9al+acZISpmizZIspsMskxyChBGk2S/778g/8E64FDLSfZEt
      WTls0dqSasa79xJLLOQPhHHsez76sM10W7LJq3NcPaHp5Cj1KXIGbZgyjb/hQFRd
      upIqR38vj6p3LN6vMCilv5lhcLnjIG/idlmHyc1MDR7f5X3c9LKWn4LoAUPy34LR
      3lZ94+u0kMQYqQ==
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIIEDTCCAvWgAwIBAgICATgwDQYJKoZIhvcNAQELBQAwgZ4xJTAjBgkqhkiG9w0B
      CQEMFmNlcnRhZG1pbkBuZXRza29wZS5jb20xGzAZBgNVBAMMEiouc2luMi5nb3Nr
      b3BlLmNvbTESMBAGA1UECwwJY2VydGFkbWluMRYwFAYDVQQKDA1OZXRza29wZSBJ
      bmMuMRIwEAYDVQQHDAlTaW5nYXBvcmUxCzAJBgNVBAgMAlNHMQswCQYDVQQGDAJT
      RzAeFw0yMjA4MjYxMTExMjhaFw0zMjA4MjMxMTExMjhaMIGeMSUwIwYJKoZIhvcN
      AQkBDBZjZXJ0YWRtaW5AbmV0c2tvcGUuY29tMRswGQYDVQQDDBIqLnNpbjIuZ29z
      a29wZS5jb20xEjAQBgNVBAsMCWNlcnRhZG1pbjEWMBQGA1UECgwNTmV0c2tvcGUg
      SW5jLjESMBAGA1UEBwwJU2luZ2Fwb3JlMQswCQYDVQQIDAJTRzELMAkGA1UEBgwC
      U0cwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCoHoeq8Je8uOUlNhLy
      sXSzZouTR4CERbydCJPr3BIz9POnWG+Ee67dAgUYaIKVPSqYVqY8LLs6g45tAELm
      oVgMnX8FbrHD29PuYYm0yqIM76eRFgIJbFjN+5ycoustHaa2J9ModL+csTyt33Y/
      5Uzdad7/YHwnVhxa2fYLmrGvxaYJJ6j4WH9k0TCZufLAyY69PWPqgI4H9gfLgBV1
      pbNS3YFqZvww+3mZIrttwoyXTwTFtWMtiwOrZ2Ila90/6zZ5GBeR0syLQ63sG0TK
      9AbmhZ0dAX3Wk8/fFluqxZS6uxlETHLXZ4o8Bp9SSEXXXPKrRBW82JWmXTEDw2LV
      N0KtAgMBAAGjUzBRMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFKHpWcD/voOM
      AAy5jQJyB0Jg0DAYMB8GA1UdIwQYMBaAFKHpWcD/voOMAAy5jQJyB0Jg0DAYMA0G
      CSqGSIb3DQEBCwUAA4IBAQCBZ3yhZyDLeKM3sBctx3k4ddwab0GFWo2vrd1Ds5A2
      tWWGOo7f7MwISXYO701ruyjIP8ZiEY+lc8I9de3FYLGUzYGCUn7QWuOD/RjKTsOg
      kj1LhMoPWg8hs81MPY6mK1FC19euidtwZAHXV4BLkECx5pJG1cqyVf5AIu1XlgDm
      9NYAP1MZDFVsvnF6EVGcbWMl2zxkTXRgJhmCWAnsPT520Uvvnff813YzfafDGzT4
      Fz3FwfJAc/+IfY+RQiVezKsk8WRRI1AEQmsRWDl6YA/pGeGvtFDQZ8dx1TACxWhW
      zSCSMuE3eKl2CWZJfwJBb5Vly5ULnRqXaB/lkAHvwvgA
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIIFWjCCA0KgAwIBAgIBATANBgkqhkiG9w0BAQsFADBEMQswCQYDVQQGEwJVUzEQ
      MA4GA1UECgwHVHJlbGxpeDEjMCEGA1UEAwwaVHJlbGxpeCBETFAgT3V0bG9vayBB
      ZGQtaW4wHhcNMjIxMDIxMTMxMDA5WhcNMzIxMDE4MTMxMDA5WjBEMQswCQYDVQQG
      EwJVUzEQMA4GA1UECgwHVHJlbGxpeDEjMCEGA1UEAwwaVHJlbGxpeCBETFAgT3V0
      bG9vayBBZGQtaW4wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/SYjS
      tfuPjt8cuq3tnUjHpblaZp9y2io9aMX5q5lVI3B5MLgvcGm3WdSDDYE9osnXcr1v
      KyvLkF4UIJbpY/YW2PJJOXDPS+N63/aWtfCdj+Lgna1RPPTUeAz6OqxTFsnGtnA8
      h/grnh59YXPcNAxuZRF51+eBaUqDHUujx0E6As+yZvGTbNUol8zEHhEjlGgB1gbv
      3G3RYua+i9NRuJQ9qEd+BlbmZrK9ZV/qmhx8BNmKuVEIssqZhv6KQ9VpZrPMoc//
      VXf4Embe19hb2gVBmGJMDxp9Rcgj73g1bCmIyJ+fcRANZnVWc3IUvP4q6pmEdFYF
      ua6D4wl5GqTPA4nqecBoL+M8FUwHVRsfQyr73ErKrR3ertqH1BJLCTHqOkk+B7FM
      6+/0eJOT9UPKP0MmzovidPr+8Uv54H4wuzL3H6JFaqUFVFHEZ0k3V3rfrVZ1fhNb
      hTcs4KI26wqesSNxKgO2N/dTv/ra/lP0f6IZb6u6a8iLUv1wxc8s220OE4WA5mYb
      cHXcJ14eMzx7dQjcMaAwYMc6dxEPYVVkbjRLsM8CcmUz3o3H1+phMIC81ZAD9vmb
      lg225SnlpUTZLxDpsh6e4yoSH8Eu169U+IurDd40X2DBUt8NU8uulPiDYhp4+0na
      px6Gdsv3YKxLZyGwPpzZtlfOXbi5Xvb2jkWqHwIDAQABo1cwVTAJBgNVHRMEAjAA
      MBQGA1UdEQQNMAuCCWxvY2FsaG9zdDATBgNVHSUEDDAKBggrBgEFBQcDATAdBgNV
      HQ4EFgQU69eH7Un9cw+9AFEpTZkCkk7Ad0UwDQYJKoZIhvcNAQELBQADggIBAHft
      IA9Lw9t2Qs7Rom+TsrRZoRO1SNLh5HM2GggDqQOwy5KDLYffX6RR3DXlWY/JF5IS
      w9of9tSgoeA+w2uYA984xgwYJST7Nj4a3lAx5XJyWBPcZvoR25LVuNnRQsx+vej/
      3ty+EbpUEycHsjcnURpZpg0dWFfvx+0bJQj35oaPPEM5qqzoKxMlEQ9Ihr8a0zFw
      USRIOMiCYasXpIHcoS8N6XSPygGkJ6Ha3xG9xU9nRSFbHS5ZpfRtjgopp9c8194x
      QL66RukJQjeqjFs5Fjolt62xT+M+hAAsSTDDVBJJ/Dc8vBrle3ouYIp7oc49SXWl
      Xaz8CcVqO36RCx4Ctk0ut2BXL/Nt4t2ijQBELNS/bdTyqG9MysE8PZiWOUoioCYI
      GuOBfLRcm6laLz8bgxlkcG0zVWJhmU/u8kXDNQ8jLtQXxkYQJ+/Ng7UyblW3B2kE
      AopSLe+gw19bl3qN1wPCgyAp3kRWZctwvrXU582nT0F4udO4uvXBkQ3gVqal45uN
      spCG/Ifko88Lhkxk2CtBspRvztT7ltRAkYF8ctWGb5p8NpoFUKfxCaLhoQZLViW9
      Xz/GQPaeZZ998dUoxJ2SWwvIMgIezuCw71hLEeu/Ygxqrv0ECBT091cXeK6Pizf6
      6PCIcDfz+N0mGUYsqZczILxd1K17ZsgyjTm7kZLW
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIIDpTCCAo2gAwIBAgIQAIH6gN6qm7NsK9Ba1UpG2DANBgkqhkiG9w0BAQsFADBf
      MRIwEAYDVQQDDAllRXllRW1zQ0ExJjAkBgkqhkiG9w0BCQEWF3N1cHBvcnRAYmV5
      b25kdHJ1c3QuY29tMRQwEgYDVQQKDAtCZXlvbmRUcnVzdDELMAkGA1UEBhMCVVMw
      HhcNMjQwMjI3MDYxNjUxWhcNMzQwMjI4MDYxNjUxWjBfMRIwEAYDVQQDDAllRXll
      RW1zQ0ExJjAkBgkqhkiG9w0BCQEWF3N1cHBvcnRAYmV5b25kdHJ1c3QuY29tMRQw
      EgYDVQQKDAtCZXlvbmRUcnVzdDELMAkGA1UEBhMCVVMwggEiMA0GCSqGSIb3DQEB
      AQUAA4IBDwAwggEKAoIBAQCLMjIeQS/30fp1Z6eAPv83uhNSQqao/Mfm+qayn/c6
      wfIfNrmMoXH67p3iN4scKMOGsnciUN5jWPLOFIlWHeR7jHKj22zam/qR7ex5Azvj
      BYfouCivVhQ5vzdtgfqHNyRqHu7zuRIJxDKKTI6GNAvakj66J8r8tzwtxLiKRh/P
      LoZllzJc+92xYLk1mDbXLxKdz8W95DCJ2EY2nqi4sO0msuzwJY2lH31uljvYPUmG
      prOAWzpYeB8DF0js56P6zO1+lcGYoweDCK2tsCZ3kOTfKA7buCmTPNvCgchZNgOv
      tEetpWYbSO2VOGbu2j47BLkghyzSqYoe3wUXZjbT1LaNAgMBAAGjXTBbMB0GA1Ud
      DgQWBBS+VcovB4vTkT+0msnXJ3n9pzgezjALBgNVHQ8EBAMCAcYwDAYDVR0TBAUw
      AwEB/zAfBgNVHSMEGDAWgBS+VcovB4vTkT+0msnXJ3n9pzgezjANBgkqhkiG9w0B
      AQsFAAOCAQEAOh8vSOLePcID+qn9fPFQuGUt6NZhn2mJwRoFfK2f2rFUWMb0yUkW
      xjvKjDLq+YLN09NDKcuFwpTGovXWwBUGIaiL+2ZLio5ArgWTYeY9LblcQ2nqvPlF
      9jpIluWX4QI1OJD9WNRNCIuL2kyK/qvUtbDcJYZp40z1nIOKB/r6csExAedAy8dQ
      36d4fAdpuX4aecc9DmpG6c2WGlcaYs2LgLQj91XYGspRuGpOwnRXayCY29W3nK0e
      5AK1zNPsF+GI93wtrlxEpKI3PlwwVqasCmCeZZ+dX+KeMHo2LoSLzRAqsbtksyGI
      6JA9HFswo+DX+SxT6WexYhs693MJPqI6og==
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIIGDDCCA/SgAwIBAgIJAJajSH5ZdwRSMA0GCSqGSIb3DQEBCwUAMIGYMQswCQYD
      VQQGEwJJRTENMAsGA1UECAwEQ29yazENMAsGA1UEBwwEQ29yazETMBEGA1UECgwK
      Rm9yY2Vwb2ludDEUMBIGA1UECwwLRGV2ZWxvcG1lbnQxEjAQBgNVBAMMCWxvY2Fs
      aG9zdDEsMCoGCSqGSIb3DQEJARYdZGFuaWVsLnNoa2x5YXJAZm9yY2Vwb2ludC5j
      b20wIBcNMjIwNDI3MTYxMzM1WhgPMjA1MjA0MTkxNjEzMzVaMIGYMQswCQYDVQQG
      EwJJRTENMAsGA1UECAwEQ29yazENMAsGA1UEBwwEQ29yazETMBEGA1UECgwKRm9y
      Y2Vwb2ludDEUMBIGA1UECwwLRGV2ZWxvcG1lbnQxEjAQBgNVBAMMCWxvY2FsaG9z
      dDEsMCoGCSqGSIb3DQEJARYdZGFuaWVsLnNoa2x5YXJAZm9yY2Vwb2ludC5jb20w
      ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCitIAjeLUJiKZ33gvHeTFr
      +RUbmzseOCt+oW2jzvhtGXF+riTqeLdCaMczFNmbVVvQ76Yrg07+ALpnv6RI2ZdW
      XffziQe+Esv2T45M+JFvk1t67kOPOV3CFE7Ihq8k8HdRqzd/sNEBoUesvGszcfeG
      81zt8Dr8Gi6Hd0VKJcz+Yhf19PnA0FyNPsM2nmq3S5G798uDoxpGnikrJMWwHXzv
      nAmCvbkGWhWanykMer8myRE0+rZZrrpdj8J7hnQRTbai1uqG3KHxk2Dsh5qWlvkG
      2k5yfx44BlO3QqoPo7nUKJEdGnyJ1O1YHxoM3Imf02ZYdgygnw5i5hzH4gAtxsXf
      wZOaAmk1dNCtSboAdjF9OBifdsZlqEZnMToS0iPyJ83bsffec+C5pAqv6qs5eXTx
      gAbBOpFohfYjk15kFG3oyzoxl5Seocft7Q3chypbjtDE+jkXiEa9wVrVfsF0Q+jM
      l1bEx+joVYw7ZXVRJ6OZZZbCnjtVGtL76XJHy2hOrhF/ThXQL8+QPOfTcyMlp3lj
      6cbO3vOxf4Oxr+OJeoE0mS/7IZRIE7Hog2OK/ngapUYcxUtklp/7J7PYi4EvZTU0
      QdNsooR1VGWa2xpoEQnjiD7QQUcEE03jWrbfVrcJVRoazm+7EkIFlxrLZlWIkxef
      IXwD+VBh8Jn6TV+k1JbTWQIDAQABo1UwUzAdBgNVHQ4EFgQUEYNZRF5jHPtiFQuP
      fAqxlS3KAl0wDAYDVR0TAQH/BAIwADAUBgNVHREEDTALgglsb2NhbGhvc3QwDgYD
      VR0PAQH/BAQDAgWgMA0GCSqGSIb3DQEBCwUAA4ICAQBlsIldLnMMfqwvbl7UCsLz
      N3fs/aMbt9vyvT60J0f6Z0fqjNWVTjm63QN7tCx2YL2yTZzD34xXMxA8PDXMqYuA
      TXNXHskckEREsh2H0lwOyTbc+9P8Z5wXcxrjavfAf325lw0d2GW4ypvbs/5hdjnu
      qicXNzT5YGiYAGm7TW1fBEgcRrZ7N5zp7rW5YTimZB1FberucXscBtLKG+Re9hke
      +5dx5Hhxhr0sHLfJpeGzK1CCInGWKADppDLy/tfGLrhvTtfcVYbpd4iUZTfQD8al
      +T6M5OAjrIUCXsWJUKua72aHvJ3uTtwHWf+Dd/p6RlErR0+hSIJIAmE3qhpiym8B
      7AgFHuM80nEZxCWoNN0b/JvOKAIsD/2448nwDuuuqQpHdK5L77SrzNNUJ/Giwcs6
      xbqow3duahdkoeAp86UuBEq8njUspNq5JLw3NJdbLRW/ltxLGK+aS+0s1nbU20tw
      XO99QL6wMYTxI76HQun4pJZ4+Pst+c23tF3E0SFbMRkoksBglBFsRjUUnqH5xyNg
      ReXDNwINEWrJy65D54xkuyqO38g1t2UvYdHbrT8h575bwxmmwinGiaNuQlchHt77
      wjakxP/Wj1hJezZf69nXKL0pDOlZXhuq93lwY9LvXbag+exfO8IZIx2P72jReWX7
      9ROd1G+aO0Yb31CpVIObOQ==
      -----END CERTIFICATE-----

      -----BEGIN CERTIFICATE-----
      MIICDjCCAbOgAwIBAgIRAN+nmjyHPxlJU74p9JKmZ1AwCgYIKoZIzj0EAwIwZjEd
      MBsGA1UEChMUT3JiU3RhY2sgRGV2ZWxvcG1lbnQxHjAcBgNVBAsMFUNvbnRhaW5l
      cnMgJiBTZXJ2aWNlczElMCMGA1UEAxMcT3JiU3RhY2sgRGV2ZWxvcG1lbnQgUm9v
      dCBDQTAeFw0yNDExMTIwOTI3MTFaFw0zNDExMTIwOTI3MTFaMGYxHTAbBgNVBAoT
      FE9yYlN0YWNrIERldmVsb3BtZW50MR4wHAYDVQQLDBVDb250YWluZXJzICYgU2Vy
      dmljZXMxJTAjBgNVBAMTHE9yYlN0YWNrIERldmVsb3BtZW50IFJvb3QgQ0EwWTAT
      BgcqhkjOPQIBBggqhkjOPQMBBwNCAASw+DBMUpMzo0eXwiMbDIP43uJYGVzuWNED
      /pXDJPEsOG6CYCcc4+uku91Je3XNkP75BKdSPaVp43QNmS0c1gMJo0IwQDAOBgNV
      HQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUzqz7uC5qgx/M
      0p6zCAnTdbmassYwCgYIKoZIzj0EAwIDSQAwRgIhALA+D0o5w1BYyTUO8KIDH7kQ
      pEdaSDYkrWVfloejJ3f5AiEA33MELs/th0G6GH1s7fnqWq4fgS65GNRkNHq7VaHw
      oc4=
      -----END CERTIFICATE-----

    ''
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
