{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    file
    bat
    glib # gio, webdav,smb mount
    fish
    elvish
    deno

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

    tmux
    fzf
    vifm
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
