{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
let

  systemd.tmpfiles.rules = [
    # 형식: "d <path> <mode> <uid> <gid> <age>"
    # %u → 실제 사용자 이름, %h → 사용자 홈 디렉토리
    "d /home/%u/src 0755 - - -"
    "d /home/%u/.local/share/nvim/ 0755 - - -"
  ];


  useunstable = system: pkg: { ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg}; };
  usenightly = system: pkg: { ${pkg} = inputs.nixpkgs-nightly.legacyPackages.${system}.${pkg}; };
  # systemd.tmpfiles.rules = [
  #   # 형식: "d <path> <mode> <uid> <gid> <age>"
  #   # %u → 실제 사용자 이름, %h → 사용자 홈 디렉토리
  #   "d /home/%u/src 0755 %u %g -"
  #   "d /home/%u/.local/share/nvim/ 0755 %u %g -"
  # ];


  # systemd.tmpfiles.settings."logs" = {
  #   "/logs" = {d.mode = "0777";};
  #   "/logs/active" = {d.mode = "0777";};
  # };

  services.openssh.settings.PasswordAuthentication = false;

  # vaultix, not sure it works
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # nix.settings.experimental-features = "nix-command flakes";
  # nix.extraOptions = ''
  #   experimental-features = nix-command flakes
  # '';

  # nix.extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
  #    "experimental-features = nix-command flakes";
  # nix.settings.experimental-features = "nix-command flakes";

  # system.activationScripts."update-hosts" = ''
  #   cat /etc/hosts > /etc/hosts.bak
  #   rm /etc/hosts
  #   cat /etc/hosts.bak "${config.age.secrets."hosts".path}" >> /etc/hosts
  # '';

  # nvimconfig = pkgs.neovimUtils.makeNeovimConfig {
  #   wrapRc = false;
  #   extraLuaPackages = p: [p.magick];
  #   extraPackages = p: [p.imagemagick];
  # };

  overlays = system: [
    inputs.nur.overlays.default



    # (system: pkg: { ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg}; })

    # (self: super: {
    #   # Replace “some-package” with the attribute name in nixpkgs
    #   nix-plugins = super.nix-plugins.overrideAttrs (oldAttrs: {
    #     # point `src` at your GitHub fork:
    #     src = super.fetchFromGitHub {
    #       owner = "aca";
    #       repo = "nix-plugins";
    #       rev = "a5e5ac4471a2a1e079e11a9c761c0e2cb145c245";
    #       hash = "sha256-1hP5PzH2bYDka7CkksZh88jKCzlSs/m4M+GmZwWjln4=";
    #     };
    #   });
    # })

    # (_: super: {
    #   nix = pkgs.wrapNeovim inputs.neovim.packages.${system}.default { };
    # })
    #
    # (_: super: {
    #   neovim =
    #     pkgs.wrapNeovimUnstable
    #     inputs.neovim.packages.${system}.default
    #     # (inputs.neovim.packages.${system}.default.overrideAttrs (oldAttrs: {
    #     #   buildInputs = oldAttrs.buildInputs ++ [super.tree-sitter];
    #     # }))
    #     nvimconfig;
    # })

    # inputs.neovim-nightly-overlay.overlays.default
    (final: prev: {
      agenix = inputs.agenix.packages.${system}.default;
      zls = inputs.zls.packages.${system}.default;
      # zig = inputs.zig.packages.${system}.default;
      unstable = import inputs.nixpkgs-unstable {
        system = system;
        config.allowUnfree = true;
      };
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
    # inputs.zig.overlays.default
    inputs.agenix.overlays.default
    (
      final: prev:
      { }
      # // (useunstable system "linuxPackages-latest")
      // (usenightly system "linuxPackages_testing")
      // (useunstable system "linuxPackages_zen")
      // (useunstable system "linuxPackages_latest")
      # // (useunstable system "attic-client")
      # // (useunstable system "attic-server")
      // (useunstable system "kotlin")
      // (useunstable system "kotlin-language-server")
      # // (useunstable system "jetbrains.idea-community-bin")
      // (useunstable system "vifm")
      // (usenightly system "go")
      // (usenightly system "pnpm")
      // (usenightly system "pnpm_10")
      # // (useunstable system "go_1_23")
      // (usenightly system "gopls")
      # // (useunstable system "pylyzer")
      // (useunstable system "vscode-langservers-extracted")
      // (usenightly system "bun")
      // (usenightly system "vector")
      // (useunstable system "ripgrep")
      # // (useunstable system "firefox")
      // (usenightly system "yt-dlp")
      # // (useunstable system "alejandra")
      // (useunstable system "deno")
      // (useunstable system "openbao")
      # // (useunstable system "rust-analyzer")
      # // (useunstable system "nodejs")
      // (useunstable system "nixd")
      // (useunstable system "bkt")
      // (useunstable system "ruff")
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
      # // (useunstable system "nixVersions.latest")
      // (useunstable system "spice-vdagent")
      // (useunstable system "nixd")
      // (useunstable system "yazi")
      // (useunstable system "bkt")
      // (useunstable system "fzf")
      // (useunstable system "pueue")
      // (useunstable system "tmux")
      // (useunstable system "qbittorrent-nox")
      // (useunstable system "wine-wayland")
      // (useunstable system "lua-language-server")
      // (useunstable system "basedpyright")
      // (useunstable system "pueue")
      // (usenightly system "aider-chat")
      // (useunstable system "uv")
      // (useunstable system "gitbutler")
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
  i18n.extraLocaleSettings = {
    # LC_ADDRESS = "en_US.UTF-8";
    # LC_IDENTIFICATION = "en_US.UTF-8";
    # LC_MEASUREMENT = "en_US.UTF-8";
    # LC_MONETARY = "en_US.UTF-8";
    # LC_NAME = "en_US.UTF-8";
    # LC_NUMERIC = "en_US.UTF-8";
    # LC_PAPER = "en_US.UTF-8";
    # LC_TELEPHONE = "en_US.UTF-8";
    # LC_TIME = "en_US.UTF-8";
    # LC_ADDRESS = "en_US.UTF-8";
    # LC_IDENTIFICATION = "en_US.UTF-8";
    # LC_MEASUREMENT = "en_US.UTF-8";
    # LC_MONETARY = "en_US.UTF-8";
    # LC_NAME = "en_US.UTF-8";
    # LC_NUMERIC = "en_US.UTF-8";
    # LC_PAPER = "en_US.UTF-8";
    # LC_TELEPHONE = "en_US.UTF-8";
    # LC_TIME = "en_US.UTF-8";
  };

  time.timeZone = "Asia/Seoul";

  services.fwupd.enable = true;

  # virtualisation.containers.enable = true;
  # virtualisation.containers.policy = {
  #   default = [{type = "insecureAcceptAnything";}];
  #   transports = {
  #     docker-daemon = {
  #       "" = [{type = "insecureAcceptAnything";}];
  #     };
  #   };
  # };

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

  environment.systemPackages = [
    # inputs.zig.packages.x86_64-linux.master
    # pkgs.ntfy-sh
    pkgs.ripgrep
    pkgs.vifm
    pkgs.pstree
    pkgs.diskus
    pkgs.fd
    # pkgs.yazi
    pkgs.age
    pkgs.ncdu
    # pkgs.xcp
    pkgs.expect
    pkgs.passage
    pkgs.rmtrash
  ];

  networking.hosts = {
    "100.127.31.30" = [ "git.internal" ];
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  environment.sessionVariables = rec {
    # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [pkgs.oracle-instantclient];
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  # nixpkgs.config.permittedInsecurePackages = [
  #   "nix-2.16.2"
  # ];

  # vaultix
  # this doesn't work in here, put it in each configuration.nix
  # systemd.sysusers.enable = true;
  services.userborn.enable = true;

  security.pki.certificateFiles = [
    ./certs/mkcert/rootCA.pem
    ./certs/txxx.crt
    ./certs/txxx2.crt
  ];
}
