{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
let
  useunstable = system: pkg: { ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${system}.${pkg}; };
  usenightly = system: pkg: { ${pkg} = inputs.nixpkgs-nightly.legacyPackages.${system}.${pkg}; };

  overlays = system: [
    inputs.nur.overlays.default

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
      rgit = inputs.rgit.packages.${system}.default;
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
      // (useunstable system "linuxPackages-latest")
      // (useunstable system "linuxPackages_testing")
      // (useunstable system "linuxPackages_zen")
      // (useunstable system "jetbrains.datagrip")
      # // (useunstable system "attic-client")
      # // (useunstable system "attic-server")
      # // (useunstable system "jetbrains.idea-community-bin")
      // (useunstable system "vifm")
      # // (usenightly system "prometheus")
      # // (usenightly system "grafana")
      # // (useunstable system "go_1_23")
      # // (useunstable system "pylyzer")

      # lang
      // (usenightly system "go")
      // (usenightly system "gopls")
      // (useunstable system "vscode-langservers-extracted")
      // (useunstable system "kotlin")
      // (useunstable system "kotlin-language-server")
      // (usenightly system "bun")
      // (useunstable system "deno")
      // (useunstable system "nixd")
      // (useunstable system "ruff")
      // (useunstable system "nixd")
      // (useunstable system "deno")
      // (useunstable system "ty")
      // (useunstable system "odin")
      // (useunstable system "ols")
      // (useunstable system "lua-language-server")
      // (useunstable system "basedpyright")
      # // (useunstable system "tailscale")

      // (usenightly system "vector")
      // (useunstable system "ripgrep")
      # // (useunstable system "firefox")
      // (usenightly system "yt-dlp")
      # // (useunstable system "alejandra")
      # // (useunstable system "openbao")
      // (useunstable system "perses")
      # // (useunstable system "rust-analyzer")
      # // (useunstable system "nodejs")
      // (useunstable system "bkt")
      // (useunstable system "vifm")
      // (useunstable system "yazi")
      // (useunstable system "bkt")
      // (useunstable system "fzf")
      # // (useunstable system "pueue")
      // (useunstable system "tmux")
      # // (useunstable system "qbittorrent-nox")
      # // (useunstable system "qbittorrent-enhanced-nox")
      // (useunstable system "wine-wayland")
      // (useunstable system "pueue")
      # // (usenightly system "aider-chat")
      # // (useunstable system "windsurf")
      # // (useunstable system "uv")
      # // (useunstable system "gitbutler")
    )
  ];
in
rec {
  nixpkgs.overlays = overlays system;
  nixpkgs.config.permittedInsecurePackages = [
    # services.matrix issue?
    "olm-3.2.16"
  ];
}
