{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    file
    bat
    fish
    elvish
    pkgs.unstable.deno

    neofetch

    hexyl

    htop
    btop
    procps
    glances
    # inetutils
    delta
    stow

    wget
    entr
    coreutils-full
    findutils
    moreutils

    atool
    curl
    xorg.luit
    diskus

    ncdu

    pkgs.unstable.tmux
    pkgs.unstable.fzf
    pkgs.unstable.vifm
    bkt

    ttyd
    just
    fd

    ripgrep
    ghq
    gron

    aria2
    pueue
    age
    recode

    ruby
    socat
    gnumake
    cmake
    ncurses

    (luajit.withPackages (p:
      with p; [
        stdlib
        inspect
      ]))
    croc
    docker-compose
  ];
}
