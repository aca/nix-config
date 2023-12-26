{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging";

    # alacritty = {
    #   url = "path:./pkgs/alacritty";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    turbo = {
      url = "github:alexghr/turborepo.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://codeberg.org/totoroot/dotfiles/src/branch/main/flake.nix

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = github:nix-community/home-manager/release-23.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # eza = {
    #   url = "github:eza-community/eza";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nur,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    agenix,
    # turbo,
    zig,
    zls,
    darwin,
    ...
  } @ inputs: let
  in {
    darwinConfigurations = {
      rok-toss = let
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
                inputs.neovim-nightly-overlay.overlay
                inputs.nixpkgs-firefox-darwin.overlay
                inputs.zig.overlays.default
                overlay-unstable
              ];
            })
            ./configuration.rok-toss.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = import ./home.rok-toss.nix;
              users.users."${username}".home = "/Users/${username}";
            }

            {
              environment.systemPackages = [
                zls.packages.aarch64-darwin.default
              ];
            }
          ];
        };
    };

    nixosConfigurations = {
      rok-toss-nix = let
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
            ({
              config,
              pkgs,
              ...
            }: {nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlay overlay-unstable];})

            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.aarch64-linux.default];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rok = import ./home.rok-toss-nix.nix;
            }
            ./configuration.rok-toss-nix.nix
          ];
        };

      rok-toss-nix-amd64 = let
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
            ({
              config,
              pkgs,
              ...
            }: {nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlay overlay-unstable];})

            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.aarch64-linux.default];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rok = import ./home.rok-toss-nix-amd64.nix;
            }
            ./configuration.rok-toss-nix-amd64.nix
          ];
        };

      root = let
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
                inputs.neovim-nightly-overlay.overlay
                inputs.zig.overlays.default
                inputs.nil.overlays.default
                overlay-unstable

                # fenix.overlays.default

                inputs.nur.overlay

                (
                  self: super: {
                    alacritty = super.alacritty.overrideAttrs (old: rec {
                      # version = "0.13.0-rc2";
                      version = "0.12.2";

                      src = super.fetchFromGitHub {
                        owner = "alacritty";
                        repo = "alacritty";
                        rev = "refs/tags/v${version}";
                        # hash = "sha256-6OhajngMr7vt+JFRYMRwKtlcvkpDGD7KeQaab+2/rsI=";
                        hash = "sha256-X3Z+f5r8surBW9FSsmWKZ/fr82ThXBUkS8fr/sTYR50=";
                        # hash = lib.fakeHash;
                      };
                      cargoDeps = old.cargoDeps.overrideAttrs (old: {
                        # name = "${name}-vendor"
                        inherit src version;
                        outputHash = "";
                        # outputHash = "";
                      });
                    });

                  }
                )

                # (self: super: {
                #   mpv-unwrapped = super.mpv-unwrapped.override {
                #     ffmpeg_5 = ffmpeg_5-full;
                #   };
                # })
                # (self: super: {
                #   advcpmv = super.callPackage ./pkgs/advcpmv.nix {pkgs = super;};
                # })
              ];
            })

            # {
            #   environment.systemPackages = [zls.packages.x86_64-linux.default];
            # }

            agenix.nixosModules.default

            {
              environment.systemPackages = [
                agenix.packages.x86_64-linux.default
                zig.packages.x86_64-linux.master
                # inputs.alacritty.defaultPackage.x86_64-linux
                # turbo.packages.x86_64-linux.default
              ];
            }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rok = import ./home.root.nix;
            }

            ./configuration.root.nix
          ];
        };

      oci-xnzm1001-001 = let
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
            ./configuration.oci-xnzm1001-001.nix
          ];
        };

      oci-xnzm1001-002 = let
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
            ./configuration.oci-xnzm1001-002.nix
          ];
        };

      rok-nuc = let
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
                inputs.neovim-nightly-overlay.overlay
                overlay-unstable
                # fenix.overlays.default
                inputs.nur.overlay
                # (self: super: {
                #   advcpmv = super.callPackage ./pkgs/advcpmv.nix {pkgs = super;};
                # })
              ];
            })

            # {
            #   environment.systemPackages = [zls.packages.x86_64-linux.default];
            # }

            agenix.nixosModules.default
            {
              environment.systemPackages = [agenix.packages.x86_64-linux.default];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rok = import ./home.rok-nuc.nix;
            }

            ./configuration.rok-nuc.nix
          ];
        };
    };
  };
}
