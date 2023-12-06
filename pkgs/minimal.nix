{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fzf
    git
    tmux
    jq
    bkt
    killall
    fd
    inetutils

    wget
    elvish
    coreutils-full
    findutils
    moreutils
    glibcLocales
    vifm
    ghq
    stow
    gnumake
    procps
    fish
    vim
  ];
}
