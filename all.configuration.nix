{
  config,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}: let
  useunstable = system: pkg: {${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg};};
  overlays = system: [
    inputs.nur.overlay
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = system;
        config.allowUnfree = true;
      };
      # neovim-custom = inputs.nixpkgs.legacyPackages.${system}.wrapNeovimUnstable
      #     (inputs.neovim-nightly-overlay.overrideAttrs (oldAttrs: {
      #     })) config;
      # });
      #

      # neovim-unwrapped = inputs.nixpkgs.legacyPackages.${system}.neovim-unwrapped.overrideAttrs (oldAttrs: {
      #   version = "master";
      #   src = builtins.fetchGit {
      #     url = "https://github.com/neovim/neovim.git";
      #   };
      #   nativeBuildInputs = inputs.nixpkgs.legacyPackages.${system}.neovim-unwrapped.nativeBuildInputs;
      # });

      # neovim-unwrapped = inputs.nixpkgs-unstable.legacyPackages.${system}.neovim-unwrapped.override {
      #   lua = inputs.nixpkgs.legacyPackages.${system}.luajit.withPackages (ps: with ps; [ magick ]);
      # };

      neovim-unwrapped =
        inputs.nixpkgs-unstable.legacyPackages.${system}.wrapNeovimUnstable
        (inputs.nixpkgs-unstable.legacyPackages.${system}.neovim-unwrapped.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [];
        })) (inputs.nixpkgs-unstable.legacyPackages.${system}.neovimUtils.makeNeovimConfig {
          extraLuaPackages = p: [p.magick];
          extraPackages = p: [p.imagemagick];
	  wrapRc = false;
        });

      # neovim-custom = inputs.neovim-nightly-overlay.packages.${system}.neovim.override {
      #   lua = inputs.nixpkgs.legacyPackages.${system}.luajit.withPackages (ps: with ps; [ magick ]);
      # };
      #
      # luajit = inputs.nixpkgs-unstable.legacyPackages.${system}.luajit.withPackages (ps: with ps; [ magick ]);
      # neovim = inputs.neovim-nightly-overlay.packages.${system}.neovim;
      # neovim = inputs.neovim-nightly-overlay.packages.${system}.neovim.override {
      #   lua = inputs.nixpkgs.legacyPackages.${system}.luajit.withPackages (ps: with ps; [ magick ]);
      # };

      # neovim-custom = inputs.neovim-nightly-overlay.packages.${system}.neovim.override {
      # };
      agenix = inputs.agenix.packages.${system}.default;
      chromium = inputs.nixpkgs.legacyPackages.${system}.chromium.override {
        commandLineArgs = [
          "--enable-quic"
          "--enable-zero-copy"
          "--remote-debugging-port=9222"
          "--remote-debugging-address=0.0.0.0"
        ];
      };
    })
    inputs.elvish.overlays.default
    inputs.zig.overlays.default
    inputs.agenix.overlays.default
    (
      final: prev:
        {}
        # // (useunstable system "linuxPackages-latest")
        // (useunstable system "linuxPackages_latest")
        # // (useunstable system "attic-client")
        # // (useunstable system "attic-server")
        // (useunstable system "linuxPackages_testing")
        // (useunstable system "linuxPackages_zen")
        // (useunstable system "vifm")
        // (useunstable system "go")
        # // (useunstable system "go_1_23")
        // (useunstable system "gopls")
        # // (useunstable system "pylyzer")
        // (useunstable system "vscode-langservers-extracted")
        // (useunstable system "bun")
        # // (useunstable system "vector")
        // (useunstable system "ripgrep")
        // (useunstable system "yt-dlp")
        # // (useunstable system "alejandra")
        // (useunstable system "deno")
        # // (useunstable system "rust-analyzer")
        # // (useunstable system "nodejs")
        // (useunstable system "nixd")
        // (useunstable system "bkt")
        // (useunstable system "vivaldi-ffmpeg-codecs")
        # // (useunstable system "chromium")
        # // (useunstable system "microsoft-edge")
        // (useunstable system "ntfy-sh")
        // (useunstable system "devenv")
        # // (useunstable system "fcitx5-qt")
        # // (useunstable system "fcitx5-lua")
        # // (useunstable system "fcitx5-chinese-addons")
        # // (useunstable system "fcitx5-mozc")
        # // (useunstable system "fcitx5-qt")
        # // (useunstable system "fcitx5-gtk")
        # // (useunstable system "fcitx5-with-addons")
        # // (useunstable system "fcitx5-hangul")
        // (useunstable system "spice-vdagent")
        # // (useunstable system "pipewire")
        // (useunstable system "deno")
        # // (useunstable system "wireplumber")
        # // (useunstable system "pwvucontrol")
        // (useunstable system "pnpm_9")
        # // (usefixed system "davinci-resolve")
        # // (useunstable system "libreoffice-qt")
        // (useunstable system "ntfy-sh")
        // (useunstable system "vifm")
        // (useunstable system "nixVersions.latest")
        // (useunstable system "spice-vdagent")
        // (useunstable system "nixd")
        // (useunstable system "bkt")
        // (useunstable system "fzf")
        // (useunstable system "pueue")
        // (useunstable system "tmux")
        // (useunstable system "qbittorrent-nox")
        // (useunstable system "lua-language-server")
        // (useunstable system "basedpyright")
        // (useunstable system "bun")
        // (useunstable system "pueue")
        // (useunstable system "yt-dlp")
        // (useunstable system "aider-chat")
        // (useunstable system "uv")
    )
  ];
in rec {
  nixpkgs.overlays = overlays system;
  # matrix issue?
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  systemd.extraConfig = ''
    #  DefaultTimeoutStopSec=240s
  '';

  services.openssh.enable = true;

  programs.git = {
    enable = true;
    config = {
      core = {
        sharedrepository = 1;
      };
      init = {
        defaultBranch = "main";
      };
      http = {
        receivepack = true;
      };
      safe = {
        directory = "*";
      };
      pull = {
        ff = "only";
      };
      "url \"ssh://rok@github.com/home/rok/src\"" = {
        "insteadOf" = "https://git.internal.home";
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;
  services.gnome.gnome-keyring.enable = true;
  imports = [
    ./env.nix
    ./dev/default_ssh.nix
    ./pkgs/scripts.nix
    ./pkgs/tmux/tmux.nix
  ];

  # Disable wait online as it's causing trouble at rebuild
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  # systemd.services.systemd-udevd.restartIfChanged = false;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  time.timeZone = "Asia/Seoul";

  services.fwupd.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.containers.policy = {
    default = [{type = "insecureAcceptAnything";}];
    transports = {
      docker-daemon = {
        "" = [{type = "insecureAcceptAnything";}];
      };
    };
  };
}
