{
  config,
  pkgs,
  lib,
  ...
}:
let
in
{
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      pkgs.fcitx5-mozc
      pkgs.fcitx5-gtk
      pkgs.fcitx5-with-addons
      pkgs.fcitx5-mozc
      # pkgs.unstable.fcitx5-qt
      # pkgs.unstable.fcitx5-chinese-addons
      pkgs.fcitx5-hangul
      # pkgs.unstable.fcitx5-lua
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # ubuntu_font_family
      noto-fonts
      # noto-fonts-cjk
      # comin
      noto-fonts-emoji
      iosevka
      # liberation_ttf
      # fira-code
      # fira-code-symbols
      # mplus-outline-fonts.githubRelease
      # nerdfonts
      # iosevka
      # iosevka-comfy.comfy
      # iosevka-comfy.comfy-duo
      # iosevka-comfy.comfy-fixed
      # iosevka-comfy.comfy-motion
      # dina-font
      # sarasa-gothic
      nanum
      # office-code-pro
      source-code-pro
      # (nerdfonts.override { fonts = [ "source-code-pro" ]; })
      # proggyfonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        sansSerif = [
          "NanumGothic"
          "Noto Sans Mono"
        ];
        monospace = [
          "NanumGothicCoding"
          "Noto Sans Mono"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs;
    [
      mkcert
      element-desktop
      ntfy-sh
      elvish
      # glxinfo
      # nvme-cli
      xwayland
    ]
    ++ [
      nftables
    ]
    ++ [
      # cloud
      awscli2
      oci-cli
    ]
    ++ [
      # cloud.k8s
      kubectl
      stern
      kubectl-images
      kubectl-node-shell
      kubectl-tree
      kubectx
      kubetail
    ]
    ++ [
    ]
    ++ [
      # system
      glances
      htop
      iftop
      usbutils
    ]
    ++ [
      # android
      # android-tools
      # android-studio
      # android-udev-rules
      # flutter
      # jdk11
      tig
      lazygit
    ]
    ++ [
      convmv # rename filename encoding
      # gimp
      # spice
      # spice-gtk
      # spice-protocol
      # win-virtio
      # win-spice
    ]
    ++ [
      # browser
      # (pkgs.unstable.microsoft-edge.override {
      #   commandLineArgs = [
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9227"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #   ];
      # })
      # (pkgs.unstable.vivaldi.override {
      #   proprietaryCodecs = true;
      #   enableWidevine = false;
      # })
      # pkgs.unstable.vivaldi-ffmpeg-codecs
      # pkgs.unstable.widevine-cdm
      # (pkgs.unstable.vivaldi.override {
      #   # mesa = pkgs.mesa;
      #   commandLineArgs = [
      #     # "--ozone-platform-hint=wayland"
      #
      #     # "--ozone-platform-hint=auto"
      #     # "--enable-features=UseOzonePlatform"
      #     # "--ozone-platform-hint=''"
      #     # "--ozone-platform=''"
      #
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9223"
      #     # "--force-dark-mode"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #     # "--disable-features=UseOzonePlatform"
      #     # "--gtk-version=4" # fcitx
      #   ];
      # })
      (pkgs.chromium.override {
        commandLineArgs = [
          # "--enable-features=WebContentsForceDark"
          "--enable-quic"
          "--enable-zero-copy"
          "--remote-debugging-port=9222"
          # NOTES: ozone-platform=wayland fcitx win+space not work
        ];
      })
      # ungoogled-chromium
      # (pkgs.google-chrome.override {
      #   commandLineArgs = [
      #     # "--enable-features=WebContentsForceDark"
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9224"
      #     # NOTES: ozone-platform=wayland fcitx win+space not work
      #   ];
      # })

      # https://github.com/fcitx/fcitx5/issues/862
      # pkgs.unstable.google-chrome

      # (pkgs.unstable.google-chrome.override {
      #   commandLineArgs = [
      #     # "--ozone-platform-hint=auto"
      #     # "--enable-features=WebContentsForceDark"
      #     # "--ozone-platform-hint=wayland"
      #     # "--enable-quic"
      #     # "--enable-zero-copy"
      #     # "--enable-features=UseOzonePlatform"
      #     # "--remote-debugging-port=9222"
      #     # "--force-dark-mode"
      #     "--gtk-version=4" # fcitx
      #   ];
      # })
    ]
    ++ [
      cmake-format
    ]
    ++ [
      pup
      socat
      # sops

      sqlite-interactive
      sublime-merge
      # git-cola
      telegram-desktop
      libnotify
      lsof
      # inkscape
      pv
    ]
    ++ [
      dig
      inetutils
      wget
      entr
      diskus
      pcmanfm
      zsh
      xsel
      gdb
      age
      aria2
      atool
      bat
      bolt
      ov
      cron
      delta
      ipset
      dig
      hyperfine
      scc
      glow
      dog
      desktop-file-utils
      entr
      pandoc
      # davinci-resolve
      dura

      # appimage-run
      # qemu
      # act


      podman
      trash-cli
      webkitgtk
      # git-annex-utils
      gnuplot
      gron
      vbindiff
      nfs-utils
      # transmission
      # transmission-remote-gtk
      hexyl
      libisoburn
      flex
      bison
      ncurses
      jo
      asciinema
      just
      kitty
      dive
      cmatrix

      sd

      grex
      gperf
      libreoffice-qt
      lnav
      lshw
      ncdu
      # neovim
      netcat-gnu
      nginx
      nnn
      # okular

      p7zip
      unzip
      ouch

      # phodav
      progress

      scrot
      mitmproxy
      (luajit.withPackages (
        p: with p; [
          stdlib
        ]
      ))

      # nqp
      rakudo
      pnpm_10

      wirelesstools

      tcpdump
      nmap
      openssl
      termshark
      tshark
      wireshark

      # terraform
      tig
      watchexec
      wev
      yarn
      zathura
      # obsidian
      zef
      patchelf
      ttyd
      powertop
      zip

      # rav1e
      #
      xxHash
      lm_sensors
      # zls

      # sway stuff
      xdragon
      alacritty # gpu accelerated terminal
      rofi-wayland
      wayland
      wdisplays
      xdg-utils
      waypipe
      wl-clipboard # clipboard
      xdg-utils # for opening default programs when clicking links
      dunst
      glib # gsettings
      dracula-theme # gtk theme
      # gnome3.adwaita-icon-theme # default gnome cursors
      pavucontrol
      swayidle
      pulseaudioFull
      grim # screenshot functionality
      slurp # screenshot functionality
      # bemenu # wayland clone of dmenu
      wdisplays # tool to configure displays
      # kanshi

      # syncthing
      mupdf
      # pueue
      # helix
      # kakoune
      gh

      # ghostty
      gtk4
      # (pkgs.makeDesktopItem {
      #   name = "ghostty";
      #   desktopName = "ghostty";
      #   exec = "/home/rok/bin/ghostty";
      #   # mimeTypes = [];
      #   # icon = "nix-snowflake";
      # })
      #
      nushell

      # woeusb

      gcc
      # wimlib
      gettext
      dnsmasq
      killall
      git
      fzf
      tmux
      fd
      ripgrep
      inetutils
      wget
      # oracle-instantclient
      coreutils-full
      findutils
      moreutils
      glibcLocales
      ghq
      stow
      # buildah
      gnumake
      procps
      procs
      fish
      # pkgs.unstable.vim
      # pkgs.unstable.jetbrains.idea-community
      ninja
      meson
      pkg-config
      libllvm
      # pkgs.unstable.yazi
      # jetbrains.datagrip
      # neovide
      # jetbrains.clion
      # emacs
      # (lowPrio uutils-coreutils-noprefix)
      # freecad-wayland
      vscode.fhs
      # detox
      unrar
      stylua
      # waypipe
      # wl-clipboard
      # xsel
      entr
      diskus
      # kooha
      # obs-studio
      zsh
      # htop
      nautilus
      cmake
      bkt

      amdgpu_top
      # pwgen
      #
      postgresql

      # (callPackage ./pkgs/vtsls.nix {inherit pkgs inputs;})
      # (callPackage ./pkgs/vtsls.nix)

      #   pdm
      #   (
      #     python3.withPackages (ps:
      #       with ps; [
      #         requests
      #         sqlite-utils
      #         boto3
      #         pyyaml
      #         yt-dlp
      #         pandas
      #         numpy
      #       ])
      #   )
    ];
}
