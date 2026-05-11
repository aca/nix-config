{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  useunstable = system: pkg: { ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg}; };
  usenightly = system: pkg: { ${pkg} = inputs.nixpkgs-nightly.legacyPackages.${system}.${pkg}; };

  # Use unstable nixos module + package overlay. Each entry: { module = "path/to/module.nix"; pkg = "pkgname"; }
  unstableModules = [
    # { module = "services/databases/victorialogs.nix"; pkg = "victorialogs"; }
    # { module = "services/networking/tailscale.nix"; pkg = "tailscale"; }
    # { module = "services/networking/zerotierone.nix"; pkg = "zerotierone"; }
  ];

  defaultOverlays = system: [
    inputs.nur.overlays.default

    (final: prev: {
      # go-nightly = inputs.nixpkgs-unstable.legacyPackages.${system}.go;
      go-nightly = inputs.nixpkgs-unstable.legacyPackages.${system}.go_1_26;
    })

    (final: prev: {
      zmx = inputs.zmx.packages.${system}.default;
    })

    # (system: pkg: { ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg}; })

    # tmux-overlay = self: super: {
    #   tmux = super.tmux.overrideAttrs (old: rec {
    #     pname = "tmux";
    #     version = "3.4-next";
    #     patches = [];
    #     src = super.fetchFromGitHub {
    #       owner = "tmux";
    #       repo = "tmux";
    #       rev = "4266d3efc89cdf7d1af907677361caa24b58c9eb";
    #       sha256 = "sha256-LliON7p1KyVucCu61sPKihYxtXsAKCvAvRBvNgoV0/g=";
    #     };
    #   });
    # };

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
      # rgit = inputs.rgit.packages.${system}.default;
      zls = inputs.zls.packages.${system}.default;
      zig = inputs.zig.packages.${system}.default;
      unstable = import inputs.nixpkgs-unstable {
        system = system;
        config.allowUnfree = true;
      };
      # chromium = inputs.nixpkgs.legacyPackages.${system}.chromium.override {
      #   commandLineArgs = [
      #     "--enable-quic"
      #     "--enable-zero-copy"
      #     "--remote-debugging-port=9222"
      #     "--remote-debugging-address=0.0.0.0"
      #   ];
      # };
    })

    inputs.claude-desktop.overlays.default

    # chrome downgrade 140 -> 139
    # https://github.com/swaywm/sway/issues/8194
    # (final: prev: {
    #   # chromium makes all electron app rebuild
    #   # chromium = inputs.nixpkgs-chrome-139.legacyPackages.${system}.chromium;
    #   google-chrome = inputs.nixpkgs-chrome-139.legacyPackages.${system}.google-chrome;
    # })

    # (final: prev: {
    #   go-nightly = inputs.nixpkgs-unstable.legacyPackages.${system}.go;
    # })

    # (final: prev: {
    #   proxyt = inputs.kata.packages.${system}.proxyt;
    # })

    inputs.android-nixpkgs.overlays.default
    inputs.elvish.overlays.default
    # inputs.zig.overlays.default
    inputs.agenix.overlays.default

    (
      final: prev:
      { }
      # // (use2411 system "x2goserver")
      # // (useunstable system "rofi")
      // (useunstable system "linuxPackages-latest")
      // (useunstable system "linuxPackages_testing")
      // (useunstable system "linuxPackages_zen")
      // (useunstable system "omnissa-horizon-client")
      // (useunstable system "claude-code-bin")
      // (useunstable system "jetbrains.datagrip")
      # // (use2405 system "zerotierone")
      # // (useunstable system "attic-client")
      # // (useunstable system "attic-server")
      # // (useunstable system "jetbrains.idea-community-bin")
      // (useunstable system "vifm")
      # // (usenightly system "prometheus")
      # // (usenightly system "grafana")
      # // (useunstable system "go_1_23")
      # // (useunstable system "pylyzer")
      # lang
      # // (usenightly system "go") # this cause too much, use nightly on home-manager
      // (useunstable system "gopls")
      // (useunstable system "vscode-langservers-extracted")
      // (useunstable system "kotlin")
      // (useunstable system "nohang")
      // (useunstable system "kotlin-language-server")
      # // (usenightly system "bun")
      # // (useunstable system "yabai")
      // (useunstable system "skhd")
      # // (useunstable system "deno")
      // (useunstable system "nixd")
      # // (useunstable system "vector")
      // (useunstable system "ruff")
      // (useunstable system "nixd")
      // (useunstable system "syncthing")
      // (useunstable system "ty")
      // (useunstable system "odin")
      // (useunstable system "tailscale")
      // (useunstable system "ols")
      // (useunstable system "lua-language-server")
      // (useunstable system "basedpyright")
      # // (useunstable system "tailscale")
      # // (usenightly system "vector")
      // (useunstable system "ripgrep")
      // (useunstable system "firefox")
      // (useunstable system "firefox-devedition")
      # // (useunstable system "alejandra")
      # // (useunstable system "openbao")
      // (useunstable system "perses")
      # // (useunstable system "rust-analyzer")
      # // (useunstable system "nodejs")
      // (useunstable system "bkt")
      # // (useunstable system "wivrn")
      # // (useunstable system "wlx-overlay-s")
      // (useunstable system "vifm")
      // (useunstable system "yazi")
      # // (useunstable system "victoriametrics") # includes victora-logs
      // (useunstable system "bkt")
      // (useunstable system "fzf")
      // (useunstable system "sway") # euler finance chrome site crash
      // (useunstable system "google-chrome")
      // (useunstable system "tmux")
      # // (useunstable system "qbittorrent-nox")
      # // (useunstable system "qbittorrent-enhanced-nox")
      # // (useunstable system "wine-wayland")
      // (useunstable system "pueue")
      # // (usenightly system "aider-chat")
      # // (useunstable system "windsurf")
      # // (useunstable system "uv")
      # // (useunstable system "gitbutler")

    )

    # package overlays for unstableModules
    (final: prev: builtins.listToAttrs (map (m: {
      name = m.pkg;
      value = inputs.nixpkgs-unstable.legacyPackages.${system}.${m.pkg};
    }) unstableModules))
  ];
in
rec {
  # use pkgs.stdenv.hostPlatform.system instead of `system` from specialArgs
  # because `system` arg to nixpkgs.lib.nixosSystem is deprecated in 25.11
  nixpkgs.overlays = defaultOverlays pkgs.stdenv.hostPlatform.system;
  nixpkgs.config.permittedInsecurePackages = [
    # services.matrix issue?
    "olm-3.2.16"
  ];

  disabledModules = map (m: m.module) unstableModules;
  imports = map (m: "${inputs.nixpkgs-unstable}/nixos/modules/${m.module}") unstableModules;
}
