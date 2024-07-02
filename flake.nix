# https://discourse.nixos.org/t/how-to-use-service-definitions-from-unstable-channel/14767/2
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-aca.url = "github:aca/nixpkgs/master";

    # NOTES: check https://status.nixos.org/ and specify the revision for cache
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?rev=818dbe2f96df233d2041739d6079bb616d3e5597";

    nur.url = "github:nix-community/NUR";
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";

    dotfiles.url = "github:aca/dotfiles";
    dotfiles.flake = false;

    # fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";

    zapret.url = "github:aca/zapret-flake/main";

    qbt-src = {
      url = "github:aca/qbittorrent-cli/master";
      flake = false;
    };

    ghostty = {
      # git@github.com:ghostty-org/ghostty.git
      # url = "git+ssh://git@github.com/ghostty-org/ghostty?rev=main";
      url = "git+ssh://git@github.com/ghostty-org/ghostty?rev=d052ada359a7dd00904373fd3a8663569a11a482";
      # url = "git+ssh://git@github.com/mitchellh/ghostty?rev=0d8aa788c504bba5e46582f016acde3835a04c74";

      # zig 0.12
      # url = "git+ssh://git@github.com/mitchellh/ghostty?rev=2f2d2c3bb123c3217b6b7ad0e9e554125acaa5f3";
      #
      # url = "git+ssh://git@github.com/aca/ghostty?ref=patch-1663";
      # url = "github.com:mitchellh/ghostty/master";
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
    # neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

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

    # eza = {
    #   url = "github:eza-community/eza";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    self,
    nur,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-aca,
    # nil,
    home-manager,
    agenix,
    dotfiles,
    # turbo,
    zig,
    zls,
    darwin,
    ...
  } @ inputs: let
    overlay-aca-aarch64-darwin = final: prev: {
      aca = import nixpkgs-aca {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    };

    overlay-aca-aarch64-linux = final: prev: {
      aca = import nixpkgs-aca {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
    };

    overlay-aca-x86_64-linux = final: prev: {
      aca = import nixpkgs-aca {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    # mul = a: (b: a * b);
    overlay-unstable = system: (
      final: prev: {
        unstable = import nixpkgs-unstable {
          system = system;
          config.allowUnfree = true;
        };
      }
    );

    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
    # tmux-overlay = self: super: {
    #   tmux = super.tmux.overrideAttrs (old: rec {
    #     pname = "tmux";
    #     version = "3.4-next";
    #
    #     patches = [];
    #     src = super.fetchFromGitHub {
    #       owner = "tmux";
    #       repo = "tmux";
    #       # rev = "refs/tags/v${version}";
    #       rev = "4266d3efc89cdf7d1af907677361caa24b58c9eb";
    #       # hash = "sha256-6OhajngMr7vt+JFRYMRwKtlcvkpDGD7KeQaab+2/rsI=";
    #       # sha256 = lib.fakeHash;
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
            nixpkgs.overlays = [
              inputs.nur.overlay
              inputs.nixpkgs-firefox-darwin.overlay
              # inputs.zig.overlays.default
              overlay-unstable
              # (self: super: {
              #   mpv-unwrapped = super.mpv-unwrapped.override {
              #     ffmpeg_5 = ffmpeg_5-full;
              #   };
              # })
            ];
          })

          ./rok-txxx.configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import ./rok-txxx.home-manager.nix;
            users.users."${username}".home = "/Users/${username}";
          }

          {
            environment.systemPackages = [
              inputs.neovim-nightly-overlay.packages.aarch64-darwin.default
              # zls.packages.aarch64-darwin.default
            ];
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
            nixpkgs.overlays = [
              inputs.elvish.overlays.default
              # inputs.templ.overlays.default
              inputs.zig.overlays.default
              # inputs.neovim-nightly-overlay.overlay
              overlay-unstable
              # overlay-aca-aarch64-linux
              # tmux-overlay
            ];
          })
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.aarch64-linux.default
              zig
              # inputs.ghostty.packages.aarch64-linux.default
              inputs.neovim-nightly-overlay.packages.aarch64-linux.default

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

    # home-manager.lib.homeManagerConfiguration {
    #   pkgs = nixpkgs.legacyPackages.${system};
    #   modules = [
    #     ./home.nix
    #     ./dunst.nix
    #     ./xscreensaver.nix
    #     {
    #       nixpkgs.overlays = [blender-bin.overlays.default]
    #       home = {
    #         inherit system username;
    #         homeDirectory = "/home/${username}";
    #       };
    #       # Update the state version as needed.
    #       stateVersion = "22.05";
    #     };
    # ];

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
    nixosConfigurations.home = let
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
            nixpkgs.overlays =
              [
                inputs.elvish.overlays.default
                # inputs.neovim-nightly-overlay.packages.aarch64-linux.default
                inputs.zig.overlays.default
                # inputs.nil.overlays.default
                # inputs.zls.overlays.default
                overlay-unstable
                # overlay-aca-x86_64-linux
                # overlay-aca-x86_64-linux
                #
                # (final: prev: {
                #   tailscale = nixpkgs-aca.pkgs.tailscale;
                # })

                # fenix.overlays.default
                inputs.nur.overlay
                # tmux-overlay
              ]
              ++ overlays;
          })

          agenix.nixosModules.default

          {
            environment.systemPackages = [
              # elvish
              # inputs.elvish.packages.x86_64-linux.default
              # inputs.neovim-nightly-overlay.packages.x86_64-linux.default
              agenix.packages.x86_64-linux.default
              #inputs.ghostty.packages.x86_64-linux.default
              inputs.watchrun.packages.x86_64-linux.default
              inputs.zapret.packages.x86_64-linux.default
              # inputs.templ.packages.x86_64-linux.default
              # inputs.fh.packages.x86_64-linux.default
              # zig.packages.x86_64-linux.master
              # inputs.zls.packages.x86_64-linux.default
              # inputs.nixpkgs-zig-0-12.legacyPackages.x86_64-linux.zig_0_12
              # inputs.alacritty.defaultPackage.x86_64-linux
              # turbo.packages.x86_64-linux.default
            ];
          }

          ./home.configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # home-manager.users.rok = (import ./home.home-manager.nix {inherit inputs;});
            home-manager.users.rok = import ./home.home-manager.nix;
            # specialArgs = {
            #   inherit inputs;
            # };
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
            nixpkgs.overlays = [
              inputs.elvish.overlays.default
              # inputs.neovim-nightly-overlay.packages.aarch64-linux.default
              inputs.zig.overlays.default
              # inputs.nil.overlays.default
              # inputs.zls.overlays.default
              overlay-unstable
              # overlay-aca-x86_64-linux
              # overlay-aca-x86_64-linux
              #
              # (final: prev: {
              #   tailscale = nixpkgs-aca.pkgs.tailscale;
              # })

              # fenix.overlays.default
              inputs.nur.overlay
              # tmux-overlay
            ];
          })

          agenix.nixosModules.default

          {
            environment.systemPackages = [
              # elvish
              # inputs.elvish.packages.x86_64-linux.default
              inputs.neovim-nightly-overlay.packages.x86_64-linux.default
              agenix.packages.x86_64-linux.default
              inputs.ghostty.packages.x86_64-linux.default
              inputs.watchrun.packages.x86_64-linux.default
              inputs.zapret.packages.x86_64-linux.default
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
            nixpkgs.overlays = [
              overlay-unstable
            ];
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
            nixpkgs.overlays = with pkgs; [
              overlay-unstable
            ];
          })

          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.x86_64-linux.default
            ];
          }
          # Gome-manager.nixosModules.home-manager
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
            nixpkgs.overlays = with pkgs; [
              overlay-unstable
              # fenix.overlays.default
              inputs.nur.overlay
            ];
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

    nixosConfigurations.archive-0 = let
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
            nixpkgs.overlays = [
              overlay-unstable
            ];
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
            nixpkgs.overlays = [
              overlay-unstable
            ];
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
          }
          ./rok-chatreey-t9.configuration.nix
        ];
      };
  };
}
