# https://ayats.org/blog/no-home-anager
{
  inputs = {
    # NOTES: check https://status.nixos.org/ and specify the revision for cache
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-fixed.url = "github:NixOS/nixpkgs?rev=8b908192e64224420e2d59dfd9b2e4309e154c5d";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";

    # nixpkgs-aca.url = "github:aca/nixpkgs/master";

    mac-app-util.url = "github:hraban/mac-app-util";
    # mac-app-util --  mktrampoline (which somescript.sh) ~/Applications/somescript.app

    autin.url = "github:atuinsh/atuin/main";
    lazybox.url = "github:aca/lazybox/main";
    # lazybox.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";

    # dotfiles.url = "codeberg:aca/dotfiles/main";
    dotfiles.url = "git+https://codeberg.org/aca/dotfiles?submodules=1";
    dotfiles.flake = false;

    scalpel.url = "github:polygon/scalpel";

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
    autin,
    # nixpkgs-aca,
    # nil,
    lazybox,
    zapret,
    home-manager,
    agenix,
    dotfiles,
    # turbo,
    mac-app-util,
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

    useunstable = system: pkg: {${pkg} = nixpkgs-unstable.legacyPackages.${system}.${pkg};};
    useunstableoverlay = system: pkg: (final: prev: {${pkg} = nixpkgs-unstable.legacyPackages.${system}.${pkg};});

    # usefixed = system: pkg: {
    #   ${pkg} = nixpkgs-fixed.legacyPackages.${system}.${pkg};
    # };

    # (final: prev: {
    #   unstable = import nixpkgs-unstable {
    #     system = system;
    #     config.allowUnfree = true;
    #   };
    # })

    overlays_dev = system: [
      inputs.nur.overlay
      (final: prev: {
        unstable = import nixpkgs-unstable {
          system = system;
          config.allowUnfree = true;
        };
        neovim = inputs.neovim-nightly-overlay.packages.${system}.default;
        agenix = inputs.agenix.packages.${system}.default;

        chromium = nixpkgs.legacyPackages.${system}.chromium.override {
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
          // (useunstable system "go")
          # // (useunstable system "go_1_23")
          // (useunstable system "gopls")
          // (useunstable system "pylyzer")
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
          # // (useunstable system "tmux")
          // (useunstable system "qbittorrent-nox")
          // (useunstable system "lua-language-server")
          // (useunstable system "basedpyright")
          // (useunstable system "bun")
          // (useunstable system "pueue")
          // (useunstable system "uv")
      )
    ];
    overlays_default = system: [
      (
        final: prev:
          {}
          // (useunstable system "linuxPackages_latest")
          // (useunstable system "vifm")
        # // (useunstable system "vector")
        # // (useunstable system "alejandra")
        # // (useunstable system "rust-analyzer")
        # // (useunstable system "nodejs")
        # // (useunstable system "firefox-devedition-bin")
        # // (useunstable system "chromium")
        # // (useunstable system "microsoft-edge")
        # // (useunstable system "pipewire")
        # // (useunstable system "wireplumber")
        # // (useunstable system "pwvucontrol")
        # // (usefixed system "davinci-resolve")
        # // (usefixed system "libreoffice-qt")
      )

      #   (final: prev: {neovim = inputs.neovim-nightly-overlay.overlays.default;})
      # (final: prev: {tmux = nixpkgs-unstable.pkgs.tmux;})
      #   (final: prev: {
      #     # bun = nixpkgs-unstable.pkgs.bun;
      #     # gopls = nixpkgs-unstable.pkgs.gopls;
      #     # fzf = nixpkgs-unstable.pkgs.fzf;
      #     # fd = nixpkgs-unstable.pkgs.fd;
      #     # ripgrep = nixpkgs-unstable.pkgs.ripgrep;
      #     # alejandra = nixpkgs-unstable.pkgs.alejandra;
      #     # deno = nixpkgs-unstable.pkgs.deno;
      #     # vector = nixpkgs-unstable.pkgs.vector;
      #   })
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
    darwinConfigurations.txxx = let
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
            nixpkgs.overlays =
              (overlays_default system)
              ++ (overlays_dev system)
              ++ [
                inputs.nixpkgs-firefox-darwin.overlay
                (useunstableoverlay system "yabai")
                (useunstableoverlay system "skhd")
              ];
          })

          ./txxx.configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.sharedModules = [mac-app-util.homeManagerModules.default];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import ./txxx.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            users.users."${username}".home = "/Users/${username}";
          }
        ];
      };

    nixosConfigurations.txxx-nix = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              inputs.agenix.packages.aarch64-linux.default
              inputs.ghostty.packages.aarch64-linux.default
              # zig
              # inputs.lazybox.packages.aarch64-linux.xxx
              # inputs.lazybox.packages.aarch64-linux.xxx2
              # inputs.nixpkgs-zig-0-12.legacyPackages.aarch64-linux.zig_0_12
              # inputs.zls.packages.aarch64-linux.default
            ];
          }
          ./txxx-nix.configuration.nix
          home-manager.nixosModules.home-manager
          {
            # https://github.com/nix-community/home-manager/issues/1698
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./txxx-nix.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "bak";
          }
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
        environment.systemPackages = [
          agenix.packages.aarch64-linux.default
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

    # .#oci-acadx0-001
    nixosConfigurations.oci-acadx0-001 = nixpkgs.lib.nixosSystem rec {
      system = "aarch64-linux";
      specialArgs = {inherit inputs system;};
      modules = [
        ./all.configuration.nix
        agenix.nixosModules.default
        {
          environment.systemPackages = [
            inputs.agenix.packages.${system}.default
          ];
        }
        ./oci-acadx0-001.configuration.nix
      ];
    };

    # .#home
    nixosConfigurations.home = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit inputs system;};
      modules = [
        ./all.configuration.nix
        agenix.nixosModules.default
        inputs.zapret.nixosModules.zapret
        ./home.configuration.nix

        home-manager.nixosModules.home-manager
        {
          # home-manager.sharedModules = [
          #   (import ./pkgs/vifm/vifmrc.nix)
          # ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rok = import ./home.home-manager.nix;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.backupFileExtension = "bak";
        }

        {
          environment.systemPackages = [
            # inputs.zapret.packages.x86_64-linux.default
            inputs.ghostty.packages.x86_64-linux.default
            inputs.agenix.packages.x86_64-linux.default
          ];
        }
      ];
    };

    # .#root
    nixosConfigurations.root = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit inputs system;};
      modules = [
        ./all.configuration.nix
        inputs.zapret.nixosModules.zapret
        agenix.nixosModules.default
        ./root.configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rok = import ./root.home-manager.nix;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.backupFileExtension = "bak";
        }

        {
          environment.systemPackages = [
            # elvish
            # inputs.elvish.packages.x86_64-linux.default
            agenix.packages.x86_64-linux.default
            # inputs.ghostty.packages.x86_64-linux.default
            inputs.watchrun.packages.x86_64-linux.default
            inputs.ghostty.packages.x86_64-linux.default
            # inputs.templ.packages.x86_64-linux.default
            # inputs.fh.packages.x86_64-linux.default
            # zig.packages.x86_64-linux.master
            # inputs.zls.packages.x86_64-linux.default
            # inputs.nixpkgs-zig-0-12.legacyPackages.x86_64-linux.zig_0_12
            # inputs.alacritty.defaultPackage.x86_64-linux
            # turbo.packages.x86_64-linux.default
          ];
        }
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

    nixosConfigurations.oci-xnzm1001-002 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
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
        ./oci-xnzm1001-002.configuration.nix
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations.oci-xnzm1001-003 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
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
        ./oci-xnzm1001-003.configuration.nix
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations.oci-acadx0-002 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
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
        ./oci-acadx0-002.configuration.nix
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations.rok-chatreey-t8 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
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
        # {
        #   environment.systemPackages = [
        #     agenix.packages.x86_64-linux.default
        #   ];
        # }
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
          nixpkgs.overlays = (overlays_default system) ++ (overlays_dev system);
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
