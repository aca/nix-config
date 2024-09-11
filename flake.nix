{
  inputs = {
    # NOTES: check https://status.nixos.org/ and specify the revision for cache
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-fixed.url = "github:NixOS/nixpkgs?rev=8b908192e64224420e2d59dfd9b2e4309e154c5d";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?rev=8b908192e64224420e2d59dfd9b2e4309e154c5d";

    # nixpkgs-aca.url = "github:aca/nixpkgs/master";

    lazybox.url = "github:aca/lazybox/main";
    # lazybox.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";

    dotfiles.url = "github:aca/dotfiles/main";
    dotfiles.flake = false;
    # dotfiles.url = "git+https://github.com/aca/dotfiles?submodules=1";

    # fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";

    zapret = {
      url = "github:aca/zapret-flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elvish-edit-elv = {
      url = "github:xiaq/edit.elv/master";
      flake = false;
    };
    elvish-utils = {
      url = "github:aca/elvish-utils/main";
      flake = false;
    };
    qbt-src = {
      url = "github:aca/qbittorrent-cli/master";
      flake = false;
    };
    sway-workspace = {
      url = "github:matejc/sway-workspace/master";
      flake = false;
    };
    vtsls = {
      url = "github:yioneko/vtsls/main";
      # url = "github:yioneko/vtsls?rev=c53d716ad44a527e21372e93fe7f2f894d2e03dd";
      flake = false;
    };

    ghostty = {
      # git@github.com:ghostty-org/ghostty.git
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
      # url = "git+ssh://git@github.com/ghostty-org/ghostty?rev=d052ada359a7dd00904373fd3a8663569a11a482";
    };

    templ.url = "github:a-h/templ";

    watchrun.url = "github:aca/watchrun/main";
    farchive.url = "github:aca/farchive/main";

    elvish.url = "github:aca/elvish/master";
    elvish.inputs.nixpkgs.follows = "nixpkgs";

    zig.url = "github:mitchellh/zig-overlay";
    zig.inputs.nixpkgs.follows = "nixpkgs";
    zls.url = "github:zigtools/zls";

    # neovim-nightly-overlay.url = { # 20240325 # url = "github:nix-community/neovim-nightly-overlay?rev=7b5ca2486bba58cac80b9229209239740b67cf90";
    #
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   # url = "github:nix-community/neovim-nightly-overlay?rev=d83afee1f19108100bd2fef1f86d87d2942d734d";
    # };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    turbo.url = "github:alexghr/turborepo.nix";

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
    };

    # Rust toolchains and rust-analyzer nightly for Nix
    fenix.url = "github:nix-community/fenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nur,
    nixpkgs,
    nixpkgs-unstable,
    # nixpkgs-fixed,
    # nixpkgs-aca,
    # nil,
    lazybox,
    zapret,
    home-manager,
    agenix,
    dotfiles,
    # turbo,
    zig,
    zls,
    darwin,
    ...
  } @ inputs: let
    # overlay-aca-x86_64-linux = final: prev: {
    #   aca = import nixpkgs-aca {
    #     system = "x86_64-linux";
    #     config.allowUnfree = true;
    #   };
    # };
    overlay-unstable = system: (
      final: prev: {
        unstable = import nixpkgs-unstable {
          system = system;
          config.allowUnfree = true;
        };
      }
    );

    useunstable = system: pkg: {
      ${pkg} = nixpkgs-unstable.legacyPackages.${system}.${pkg};
    };

    useunstableoverlay = system: pkg: (final: prev: { ${pkg} = nixpkgs-unstable.legacyPackages.${system}.${pkg}; });

    # usefixed = system: pkg: {
    #   ${pkg} = nixpkgs-fixed.legacyPackages.${system}.${pkg};
    # };

    overlays_dev = system: [
      (final: prev: {
        # unstable = import nixpkgs-unstable {
        #   system = system;
        #   config.allowUnfree = true;
        # };
        neovim = inputs.neovim-nightly-overlay.packages.${system}.default;
        # zapret = inputs.zapret.overrideAttrs (old: {config = "werwerwe";});
      })
      inputs.elvish.overlays.default
      inputs.zig.overlays.default
      inputs.agenix.overlays.default
      (
        final: prev:
          {}
          // (useunstable system "tmux")

          // (useunstable system "go")
          // (useunstable system "go_1_23")
          // (useunstable system "gopls")

          // (useunstable system "pylyzer")
          // (useunstable system "vscode-langservers-extracted")

          // (useunstable system "bun")
          # // (useunstable system "vector")
          // (useunstable system "gopls")
          // (useunstable system "ripgrep")
          # // (useunstable system "alejandra")
          // (useunstable system "deno")
          # // (useunstable system "rust-analyzer")
          # // (useunstable system "nodejs")
          // (useunstable system "nixd")
          // (useunstable system "bkt")
          // (useunstable system "pueue")
          // (useunstable system "vivaldi")
          // (useunstable system "vivaldi-ffmpeg-codecs")
          # // (useunstable system "chromium")
          # // (useunstable system "microsoft-edge")
          // (useunstable system "ntfy-sh")
          // (useunstable system "fzf")

          // (useunstable system "fcitx5-qt")
          // (useunstable system "fcitx5-lua")
          // (useunstable system "fcitx5-chinese-addons")
          // (useunstable system "fcitx5-mozc")
          // (useunstable system "fcitx5-qt")
          // (useunstable system "fcitx5-gtk")
          // (useunstable system "fcitx5-with-addons")
          // (useunstable system "fcitx5-hangul")
          // (useunstable system "spice-vdagent")
          // (useunstable system "linuxPackages-latest")
        # // (useunstable system "pipewire")
        # // (useunstable system "wireplumber")
        # // (useunstable system "pwvucontrol")
        # // (usefixed system "davinci-resolve")
        # // (usefixed system "libreoffice-qt")
      )
    ];
    overlays_default = system: [
      (
        final: prev:
          {}
          // (useunstable system "tmux")
          // (useunstable system "bun")
          # // (useunstable system "vector")
          // (useunstable system "gopls")
          // (useunstable system "ripgrep")
          # // (useunstable system "alejandra")
          // (useunstable system "deno")
          // (useunstable system "go")
          # // (useunstable system "rust-analyzer")
          # // (useunstable system "nodejs")
          // (useunstable system "nixd")
          // (useunstable system "bkt")
          // (useunstable system "pueue")
          // (useunstable system "pnpm_9")
          # // (useunstable system "firefox-devedition-bin")
          // (useunstable system "vivaldi")
          // (useunstable system "vivaldi-ffmpeg-codecs")
          # // (useunstable system "chromium")
          # // (useunstable system "microsoft-edge")
          // (useunstable system "ntfy-sh")
          // (useunstable system "fzf")
          // (useunstable system "fcitx5-qt")
          // (useunstable system "fcitx5-lua")
          // (useunstable system "fcitx5-chinese-addons")
          // (useunstable system "fcitx5-mozc")
          // (useunstable system "fcitx5-qt")
          // (useunstable system "fcitx5-gtk")
          // (useunstable system "fcitx5-with-addons")
          // (useunstable system "fcitx5-hangul")
          // (useunstable system "spice-vdagent")
          // (useunstable system "linuxPackages-latest")
        # // (useunstable system "pipewire")
        # // (useunstable system "wireplumber")
        # // (useunstable system "pwvucontrol")
        # // (usefixed system "davinci-resolve")
        # // (usefixed system "libreoffice-qt")
      )

      #   (final: prev: {neovim = inputs.neovim-nightly-overlay.overlays.default;})
      # (final: prev: {tmux = nixpkgs-unstable.pkgs.tmux;})
      #   (final: prev: {
      #     # vifm = nixpkgs-unstable.pkgs.vifm;
      #     # bun = nixpkgs-unstable.pkgs.bun;
      #     # gopls = nixpkgs-unstable.pkgs.gopls;
      #     # fzf = nixpkgs-unstable.pkgs.fzf;
      #     # fd = nixpkgs-unstable.pkgs.fd;
      #     # ripgrep = nixpkgs-unstable.pkgs.ripgrep;
      #     # alejandra = nixpkgs-unstable.pkgs.alejandra;
      #     # deno = nixpkgs-unstable.pkgs.deno;
      #     # vector = nixpkgs-unstable.pkgs.vector;
      #   })
      inputs.nur.overlay
      # ( self: super: {
      #  tmux = super.tmux.overrideAttrs (old: rec {
      #    pname = "tmux";
      #    version = "3.4-next";
      #    patches = [];
      #    src = super.fetchFromGitHub {
      #      owner = "tmux";
      #      repo = "tmux";
      #      rev = "4266d3efc89cdf7d1af907677361caa24b58c9eb";
      #      sha256 = "sha256-LliON7p1KyVucCu61sPKihYxtXsAKCvAvRBvNgoV0/g=";
      #    };
      #    }))};
    ];
    # overlays = [
    #   inputs.neovim-nightly-overlay.overlays.default
    # ];
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
  in {
    darwinConfigurations.rok-txxx = let
      username = "kyungrok.chung";
      system = "aarch64-darwin";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      inputs.darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = (overlays_default system) ++ (overlays_dev system)
              ++ [
                inputs.nixpkgs-firefox-darwin.overlay
               (useunstableoverlay system "yabai")
               (useunstableoverlay system "skhd")
              ];
          })

          ./rok-txxx.configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import ./rok-txxx.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            users.users."${username}".home = "/Users/${username}";
          }
        ];
      };

    nixosConfigurations.rok-txxx-nix = let
      system = "aarch64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        specialArgs = {inherit inputs;};
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = (overlays_default system) ++ (overlays_dev system);
          })
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.aarch64-linux.default
              # zig
              # inputs.ghostty.packages.aarch64-linux.default
              # inputs.lazybox.packages.aarch64-linux.xxx
              # inputs.lazybox.packages.aarch64-linux.xxx2
              # inputs.nixpkgs-zig-0-12.legacyPackages.aarch64-linux.zig_0_12
              # inputs.zls.packages.aarch64-linux.default
            ];
          }
          home-manager.nixosModules.home-manager
          {
            # https://github.com/nix-community/home-manager/issues/1698
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./rok-txxx-nix.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
          }
          ./rok-txxx-nix.configuration.nix
        ];
      };

    # home-manager switch switch --flake '.#rok@root'
    homeConfigurations."rok@home" = let
    in
      home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home.home-manager.nix
          {
            nixpkgs.overlays = [
              (overlay-unstable "x86_64-linux")
              inputs.nur.overlay
              # emacs-overlay.overlay
              # nixpkgs-f2k.overlays.window-managers
            ];
          }
        ];
      };

    homeConfigurations."rok@root" = let
    in
      home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./root.home-manager.nix
          {
            nixpkgs.overlays = [
              (overlay-unstable "x86_64-linux")
              inputs.nur.overlay
              # emacs-overlay.overlay
              # nixpkgs-f2k.overlays.window-managers
            ];
          }
        ];
      };

    # .#home
    nixosConfigurations.home = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ({
          config,
          pkgs,
          ...
        }: {
          nixpkgs.overlays = (overlays_default system)++ (overlays_dev system);
        })

        agenix.nixosModules.default

        {
          environment.systemPackages = [
            inputs.ghostty.packages.x86_64-linux.default
            # inputs.zapret.packages.x86_64-linux.default
          ];
        }

        inputs.zapret.nixosModules.zapret
        # {
        #   zapret.zapretconfig = "";
        # }

        ./home.configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rok = import ./home.home-manager.nix;
          home-manager.extraSpecialArgs = specialArgs;
        }
      ];
    };

    nixosConfigurations.root = let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = overlays_default system;
          })

          agenix.nixosModules.default

          {
            environment.systemPackages = [
              # elvish
              # inputs.elvish.packages.x86_64-linux.default
              agenix.packages.x86_64-linux.default
              # inputs.ghostty.packages.x86_64-linux.default
              inputs.watchrun.packages.x86_64-linux.default
              # inputs.templ.packages.x86_64-linux.default
              # inputs.fh.packages.x86_64-linux.default
              # zig.packages.x86_64-linux.master
              # inputs.zls.packages.x86_64-linux.default
              # inputs.nixpkgs-zig-0-12.legacyPackages.x86_64-linux.zig_0_12
              # inputs.alacritty.defaultPackage.x86_64-linux
              # turbo.packages.x86_64-linux.default
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./root.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
          }

          ./root.configuration.nix
        ];
      };

    nixosConfigurations.oci-impxmon-003 = let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        modules = [
          agenix.nixosModules.default
          ./oci-impxmon-003.configuration.nix

          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = overlays_default system;
          })
        ];
      };

    nixosConfigurations.oci-xnzm1001-001 = let
      system = "aarch64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        modules = [
          agenix.nixosModules.default
          ./oci-xnzm1001-001.configuration.nix
        ];
      };

    nixosConfigurations.oci-xnzm1001-002 = let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        modules = [
          ./oci-xnzm1001-002.configuration.nix
        ];
      };

    nixosConfigurations.rok-chatreey-t8 = let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = overlays_default system;
          })

          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.x86_64-linux.default
            ];
          }
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.rok = import ./home.rok-chatreey-t9.nix;
          # }
          ./rok-chatreey-t8.configuration.nix
        ];
      };

    nixosConfigurations.rok-nuc = let
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = overlays_default system;
          })

          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.x86_64-linux.default
            ];
          }
          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./rok-nuc.home-manager.nix;
          }

          ./rok-nuc.configuration.nix
        ];
      };

    nixosConfigurations.archive-0 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ({
          config,
          pkgs,
          ...
        }: {
          nixpkgs.overlays = overlays_default system;
        })

        agenix.nixosModules.default

        {
          environment.systemPackages = [
            agenix.packages.x86_64-linux.default
            inputs.elvish.packages.x86_64-linux.default
            inputs.farchive.packages.x86_64-linux.default
          ];
        }
        # home-manager.nixosModules.home-manager
        # {
        #   home-manager.useGlobalPkgs = true;
        #   home-manager.useUserPackages = true;
        #   home-manager.users.rok = import ./home.rok-chatreey-t9.nix;
        # }
        ./archive-0.configuration.nix
      ];
    };

    nixosConfigurations.rok-chatreey-t9 = let
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      nixpkgs.lib.nixosSystem rec {
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.overlays = overlays_default system;
          })

          agenix.nixosModules.default

          {
            environment.systemPackages = [
              agenix.packages.x86_64-linux.default
            ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./rok-chatreey-t9.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
          }
          ./rok-chatreey-t9.configuration.nix
        ];
      };
  };
}
