{
  # config,
  pkgs,
  options,
  lib,
  ...
}: let
in {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # environment.systemPackages = with pkgs; [
  #   git
  #   vim
  # ];

  environment.systemPackages = with pkgs; [
    # (import ../pkgs/advcpmv/default.nix)

aider-chat
neovim-unwrapped

shpool
   gdu
    git
    git-lfs
    # jujutsu
    bun
    # neovim
    cargo
    git-branchless
    gtrash

    file
    bat

    # blesh

    zsh
    fish
    deno

    caddy
    nss.tools
    neofetch

    hexyl

    htop
    iftop
    glances
    btop
    procps
    # inetutils
    delta
    # psmisc # not on darwin
    stow

    wget
    entr
    httpie

hyperfine
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
    natscli
    imagemagick
    nats-server
    zellij
    # tmux
    fzf
    bkt

    nnn

    ttyd
    tig
    just

    # sublime-merge
    openssh
    fd
    vector
    bmon
    nload
    ripgrep
    ghq
    vifm
    # neovim
    # ydotool
    vim
    gron

    aria2
    pueue
    age
    recode

    ruby

    # coreutils
    # gcc
    gettext
    ninja
    meson
    # pkg-config
    clang
    clang-tools_16
    socat
    gnumake
    cmake
    ncurses

    # (luajit.withPackages (p:
    #   with p; [
    #     stdlib
    #     inspect
    #   ]))

    # (lua.withPackages (p:
    #   with p; [
    #     stdlib
    #     luarocks-nix
    #     inspect
    #   ]))


    #  rustc
    #  cargo


    #  nodejs_20
    #  # nodePackages_latest.node-gyp
    #  nodePackages_latest.pnpm
    #  nodePackages_latest.pyright
    #  nodePackages_latest.prettier
    #  nodePackages_latest.yaml-language-server
    #  nodePackages_latest.vscode-langservers-extracted
    #  nodePackages_latest.sql-formatter

    #  nixos-shell

    #  lazygit

    #  # dive
    #  croc

    # # docker-compose
  ];
}
