{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}:
let
  useunstable = system: pkg: { ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg}; };
  usenightly = system: pkg: { ${pkg} = inputs.nixpkgs-nightly.legacyPackages.${system}.${pkg}; };

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [
    "root"
    "rok"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # nvimconfig = pkgs.neovimUtils.makeNeovimConfig {
  #   wrapRc = false;
  #   extraLuaPackages = p: [p.magick];
  #   extraPackages = p: [p.imagemagick];
  # };

  overlays = system: [
    inputs.nur.overlays.default

    # (_: super: {
    #   neovim =
    #     pkgs.wrapNeovim inputs.neovim.packages.${system}.default {
    #     };
    # })

    # (_: super: {
    #   neovim =
    #     pkgs.wrapNeovimUnstable
    #     inputs.neovim.packages.${system}.default
    #     # (inputs.neovim.packages.${system}.default.overrideAttrs (oldAttrs: {
    #     #   buildInputs = oldAttrs.buildInputs ++ [super.tree-sitter];
    #     # }))
    #     nvimconfig;
    # })

    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = system;
        config.allowUnfree = true;
      };
      agenix = inputs.agenix.packages.${system}.default;
      zls = inputs.zls.packages.${system}.default;
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

    (self: super: {
      weechat = super.weechat.override {
        configure =
          { availablePlugins, ... }:
          {
            scripts = with super.weechatScripts; [
              # weechat-otr
              wee-slack
            ];
            # Uncomment this if you're on Darwin, there's no PHP support available. See https://github.com/NixOS/nixpkgs/blob/e6bf74e26a1292ca83a65a8bb27b2b22224dcb26/pkgs/applications/networking/irc/weechat/wrapper.nix#L13 for more info.
            # plugins = builtins.attrValues (builtins.removeAttrs availablePlugins [ "php" ]);
          };
      };
    })

    (
      final: prev:
      { }
      # // (useunstable system "linuxPackages-latest")
      // (useunstable system "linuxPackages_latest")
      # // (useunstable system "attic-client")
      # // (useunstable system "attic-server")
      // (useunstable system "linuxPackages_testing")
      // (useunstable system "linuxPackages_zen")
      // (useunstable system "vifm")
      // (usenightly system "go")
      // (usenightly system "pnpm")
      // (usenightly system "pnpm_10")
      # // (useunstable system "go_1_23")
      // (usenightly system "gopls")
      # // (useunstable system "pylyzer")
      // (useunstable system "vscode-langservers-extracted")
      // (usenightly system "bun")
      # // (useunstable system "vector")
      // (useunstable system "ripgrep")
      // (usenightly system "yt-dlp")
      # // (useunstable system "alejandra")
      // (useunstable system "deno")
      # // (useunstable system "rust-analyzer")
      # // (useunstable system "nodejs")
      // (useunstable system "nixd")
      // (useunstable system "bkt")
      // (useunstable system "vivaldi-ffmpeg-codecs")
      # // (useunstable system "chromium")
      # // (useunstable system "microsoft-edge")
      # // (useunstable system "ntfy-sh")
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
      # // (useunstable system "ntfy-sh")
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
      // (useunstable system "pueue")
      // (usenightly system "aider-chat")
      // (useunstable system "uv")
    )
  ];
in
rec {
  nixpkgs.overlays = overlays system;

  nixpkgs.config.permittedInsecurePackages = [
    # matrix issue?
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
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "en_US.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "en_US.UTF-8";
  #   LC_TIME = "en_US.UTF-8";
  # };

  time.timeZone = "Asia/Seoul";

  services.fwupd.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.containers.policy = {
    default = [ { type = "insecureAcceptAnything"; } ];
    transports = {
      docker-daemon = {
        "" = [ { type = "insecureAcceptAnything"; } ];
      };
    };
  };

  systemd.tmpfiles.settings."logs" = {
    "/logs" = {
      d.mode = "0777";
    };
    "/logs/active" = {
      d.mode = "0777";
    };
  };
  systemd.tmpfiles.settings."kv" = {
    "/var/cache/kv" = {
      d.mode = "0777";
    };
  };

  services.vector.journaldAccess = true;
  services.vector.enable = true;
  services.vector.settings = builtins.fromTOML (builtins.readFile ./vector.toml);

  environment.systemPackages = [
    pkgs.ntfy-sh
    pkgs.diskus
    pkgs.fd
    pkgs.ncdu
    pkgs.expect
  ];

  networking.hosts = {
    "100.127.31.30" = [ "git.internal" ];
    "100.115.43.17" = [ "torrent.internal" ];
  };

  # networking.search = [
  #   "folk-uaru.ts.net."
  # ];

  systemd.services."notify-send-fail@" = {
    enable = true;
    description = "service fail notification for %i";
    scriptArgs = "%i";
    script = ''
      notify-send -u critical "$1"
    '';
  };

  security.pki.certificateFiles = [
    ./certs/mkcert/rootCA.pem
  ];
}
