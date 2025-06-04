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
      // (useunstable system "linuxPackages_latest")
      # // (useunstable system "attic-client")
      # // (useunstable system "attic-server")
      // (useunstable system "kotlin")
      // (useunstable system "kotlin-language-server")
      # // (useunstable system "jetbrains.idea-community-bin")
      // (useunstable system "vifm")
      // (usenightly system "go")
      // (usenightly system "prometheus")
      // (usenightly system "grafana")
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
      # // (useunstable system "vivaldi-ffmpeg-codecs")
      # // (useunstable system "chromium")
      # // (useunstable system "microsoft-edge")
      # // (useunstable system "ntfy-sh")
      # // (useunstable system "devenv")
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
      # // (usenightly system "aider-chat")
      # // (useunstable system "windsurf")
      # // (useunstable system "uv")
      # // (useunstable system "gitbutler")
      // (useunstable system "odin")
      // (useunstable system "ols")
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
