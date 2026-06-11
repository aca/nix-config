{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    lua-language-server


    (lua5_4_compat.withPackages (p:
      with p; [
        stdlib
        tl
        teal-language-server
      ]))


    (luajit.withPackages (p:
      with p; [
        stdlib
        luarocks
      ]))

  ];
}
