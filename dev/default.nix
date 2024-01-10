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
    inetutils
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

    tmux
    pkgs.unstable.bkt
    pkgs.unstable.fzf
    pkgs.unstable.nnn
    pkgs.unstable.ttyd
    pkgs.unstable.tig
    # pkgs.unstable.tmux
    pkgs.unstable.just
    pkgs.unstable.fd
    pkgs.unstable.ripgrep
    pkgs.unstable.ghq
    pkgs.unstable.vifm
    pkgs.unstable.elvish
    pkgs.unstable.gron

    pkgs.unstable.aria2
    pkgs.unstable.pueue
    pkgs.unstable.age
    pkgs.unstable.alejandra
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
    nodePackages_latest.yaml-language-server
    nodePackages_latest.vscode-langservers-extracted

    php82
    php82Packages.composer
    gcc

    pkgs.unstable.alejandra
    lazygit
  ];
}
