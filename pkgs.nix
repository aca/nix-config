{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    jq
    gcc
    gettext
    killall
    fd
    inetutils
    wget
    elvish
    vifm
    ghq
    stow
    gnumake
    fish
  ];
}
