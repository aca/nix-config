{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    file

    zsh
    fish
    deno

    hexyl
    # pkgs.unstable.deno

    htop
    btop
    procps
    # inetutils
    delta
    # psmisc # not on darwin
    stow

    wget
    entr

    # glibcLocales

    coreutils-full
    findutils
    moreutils

    atool
    curl
    xorg.luit
    sops
    diskus

    stylua
    # ncdu

    pkgs.unstable.tmux
    bkt
    fzf
    nnn
    ttyd
    tig
    # pkgs.unstable.tmux
    just
    fd
    ripgrep
    ghq
    pkgs.unstable.vifm
    pkgs.unstable.yazi
    pkgs.unstable.elvish
    gron

    aria2
    pueue
    age
    recode

    ruby

    # coreutils

    # pkgs.unstable.deno

    # pkgs.unstable.vector

    # gcc
    gettext
    ninja
    meson
    pkg-config
    clang
    clang-tools_16
    socat
    gnumake
    cmake
    ncurses

    (luajit.withPackages (p:
      with p; [
        stdlib
        inspect
      ]))

    # (lua.withPackages (p:
    #   with p; [
    #     stdlib
    #     luarocks-nix
    #     inspect
    #   ]))

    pkgs.unstable.lua-language-server

    rustc
    cargo

    nodejs_20
    nodePackages_latest.node-gyp
    nodePackages_latest.pnpm
    nodePackages_latest.pyright
    nodePackages_latest.prettier
    pkgs.unstable.biome
    nodePackages_latest.yaml-language-server
    nodePackages_latest.vscode-langservers-extracted
    nodePackages_latest.sql-formatter
    # pkgs.unstable.uutils-coreutils-noprefix

    # pkgs.unstable.alacritty
    # php82
    # php82Packages.composer

    pkgs.unstable.alejandra
    pkgs.unstable.nixd

    lazygit

    # dive
    croc
  ];
}
