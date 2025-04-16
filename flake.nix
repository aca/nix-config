# https://ayats.org/blog/no-home-anager
{
  inputs = {
    # NOTES: check https://status.nixos.org/ and specify the revision for cache
    nixpkgs.url = "github:nixos/nixpkgs/master";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs?rev=f675531bc7e6657c10a18b565cfebd8aa9e24c14";
    # nixpkgs-nightly.url = "github:NixOS/nixpkgs?rev=f675531bc7e6657c10a18b565cfebd8aa9e24c14";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    nixpkgs-nightly.url = "github:NixOS/nixpkgs/master";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    vaultix.url = "github:milieuim/vaultix";

    # nixpkgs-aca.url = "github:aca/nixpkgs/master";

    mac-app-util.url = "github:hraban/mac-app-util";
    # mac-app-util --  mktrampoline (which somescript.sh) ~/Applications/somescript.app

    # autin.url = "github:atuinsh/atuin/main";
    xbox.url = "github:aca/xbox/main";
    xbox.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";

    # dotfiles.url = "codeberg:aca/dotfiles/main";
    dotfiles.url = "git+https://codeberg.org/aca/dotfiles?submodules=0";
    dotfiles.flake = false;

    scalpel.url = "github:polygon/scalpel";

    # zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";

    # zapret = {
    #   url = "github:aca/zapret-flake/main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    comin = {
      url = "github:nlewo/comin";
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
    # qbt-src = {
    #   url = "github:aca/qbittorrent-cli/master";
    #   flake = false;
    # };
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
      # url = "github:ghostty-org/ghostty/main";
      url = "github:ghostty-org/ghostty/main";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };

    templ.url = "github:a-h/templ";

    watchrun.url = "github:aca/watchrun/main";
    farchive.url = "github:aca/farchive/main";

    elvish.url = "github:aca/elvish/master";
    # elvish.inputs.nixpkgs.follows = "nixpkgs";

    zig.url = "github:mitchellh/zig-overlay";
    zig.inputs.nixpkgs.follows = "nixpkgs";
    zls.url = "github:zigtools/zls";

    # neovim.url = "github:nix-community/neovim-nightly-overlay?rev=1b82dbcbbcba812ad19f5c0601d1731731bf4ebe";
    neovim.url = "github:nix-community/neovim-nightly-overlay?rev=5055d63816f4e516cb4a6f75222b95f12757bea7";
    # neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    turbo.url = "github:alexghr/turborepo.nix";

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust toolchains and rust-analyzer nightly for Nix
    fenix.url = "github:nix-community/fenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nur,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-nightly,
    # nixpkgs-fixed,
    # autin,
    # nixpkgs-aca,
    # nil,
    # lazybox,
    # zapret,
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
    overlay-unstable = system: (final: prev: {
      unstable = import nixpkgs-unstable {
        system = system;
        config.allowUnfree = true;
      };
    });

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

    overlays_default = system: [
      (
        final: prev: {} // (useunstable system "linuxPackages_latest") // (useunstable system "vifm")
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
  in
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
    {
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
          specialArgs = {inherit inputs system;};
          modules = [
            # ./all.configuration.nix
            (
              {
                config,
                pkgs,
                ...
              }: {
                nixpkgs.overlays =
                  (overlays_default system)
                  ++ [
                    inputs.nur.overlays.default
                    inputs.nixpkgs-firefox-darwin.overlay
                    (useunstableoverlay system "yabai")
                    (useunstableoverlay system "skhd")
                  ];
              }
            )

            {
              environment.systemPackages = [
                # inputs.zapret.packages.x86_64-linux.default
                # inputs.zen-browser.packages.${system}.twilight-official
                # inputs.ghostty.packages.${system}.default
                # inputs.zen-browser.packages."${system}".default
                inputs.agenix.packages.${system}.default
              ];
            }

            ./txxx.configuration.nix
            ./neovim.nix
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
          inputs.comin.nixosModules.comin
          ./all.configuration.nix
          ./linux.configuration.nix
          ./neovim.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              inputs.agenix.packages.aarch64-linux.default
              # inputs.zen-browser.packages.aarch64-linux.twilight-official
              inputs.ghostty.packages.aarch64-linux.default
              # zig
              # inputs.lazybox.packages.aarch64-linux.xxx2
              # inputs.nixpkgs-zig-0-12.legacyPackages.aarch64-linux.zig_0_12
              # inputs.zls.packages.aarch64-linux.default
            ];
          }
          (
            {...}: {
              services.comin = {
                enable = false;
                remotes = [
                  {
                    name = "origin";
                    url = "https://codeberg.org/aca/nix-config.git";
                    branches.main.name = "main";
                    poller.period = 30;
                  }
                ];
              };
            }
          )
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

      # let
      #   system = "aarch64-linux";
      #   pkgs = nixpkgs.legacyPackages.${system};
      # in {
      #   homeConfigurations."rok" = home-manager.lib.homeManagerConfiguration {
      #     inherit pkgs;
      #
      #     # Specify your home configuration modules here, for example,
      #     # the path to your home.nix.
      #     modules = [ ./home.nix ];
      #
      #     # Optionally use extraSpecialArgs
      #     # to pass through arguments to home.nix
      #   };
      # };

      homeConfigurations."rok@txxx-nix" = let
        system = "aarch64-linux";
      in
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {inherit inputs;};
          modules = [
            ./txxx-nix.home-manager.nix
            {
              nixpkgs.overlays = [
                # (overlay-unstable )
                inputs.nur.overlays.default
                # emacs-overlay.overlay
                # nixpkgs-f2k.overlays.window-managers
              ];
            }
          ];
        };

      # # home-manager switch switch --flake '.#rok@txxx-nix'
      # homeConfigurations."rok@txxx-nix" = home-manager.lib.homeManagerConfiguration {
      #   # pkgs = nixpkgs.legacyPackages.aarch64-linux;
      #   # extraSpecialArgs = { inherit inputs; };
      #   modules = [
      #     import ./txxx-nix.home-manager.nix
      #     {
      #       inherit nixpkgs home-manager;
      #     }
      #     # {
      #     #   nixpkgs.overlays = [
      #     #     # inputs.nur.overlays.default
      #     #     inputs.nur.overlays.default
      #     #   ];
      #     # }
      #   ];
      # };

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
                inputs.nur.overlays.default
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
                inputs.nur.overlays.default
                # emacs-overlay.overlay
                # nixpkgs-f2k.overlays.window-managers
              ];
            }
          ];
        };

      # .#oci-aca-001
      nixosConfigurations.oci-aca-001 = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = {inherit inputs system self;};
        modules = [
          inputs.comin.nixosModules.comin
          ./all.configuration.nix
          # inputs.vaultix.nixosModules.default
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              inputs.agenix.packages.${system}.default
            ];
          }
          ./oci-aca-001.configuration.nix
          (
            {...}: {
              services.comin = {
                enable = true;
                remotes = [
                  {
                    name = "origin";
                    url = "https://codeberg.org/aca/nix-config.git";
                    branches.main.name = "main";
                    poller.period = 30;
                  }
                ];
              };
            }
          )
          home-manager.nixosModules.home-manager
          {
            # home-manager.sharedModules = [
            #   (import ./pkgs/vifm/vifmrc.nix)
            # ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./oci-aca-001.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "bak";
          }
        ];
      };

      # .#home
      nixosConfigurations.home = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          agenix.nixosModules.default
          ./home.configuration.nix
          ./neovim.nix

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
              # inputs.zen-browser.packages.${system}.twilight-official
              inputs.ghostty.packages.${system}.default
              # inputs.zen-browser.packages."${system}".default
              inputs.agenix.packages.${system}.default
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

      nixosConfigurations.oci-impx-001 = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          inputs.comin.nixosModules.comin
          ./all.configuration.nix
          ./log.nix
          ./oci-impx-001.configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./oci-impx-001.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "bak";
          }
          agenix.nixosModules.default
          (
            {...}: {
              services.comin = {
                enable = true;
                remotes = [
                  {
                    name = "origin";
                    url = "https://codeberg.org/aca/nix-config.git";
                    branches.main.name = "main";
                    poller.period = 10;
                  }
                ];
              };
            }
          )
        ];
      };

      # nixosConfigurations.oci-impx-002 = nixpkgs.lib.nixosSystem rec {
      #   system = "x86_64-linux";
      #   specialArgs = {inherit inputs system;};
      #   modules = [
      #     ./all.configuration.nix
      #     ./oci-impx-002.configuration.nix
      #     agenix.nixosModules.default
      #   ];
      # };

      nixosConfigurations.oci-impx-003 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          inputs.comin.nixosModules.comin
          ./all.configuration.nix
          ./oci-impx-003.configuration.nix
          agenix.nixosModules.default
          (
            {...}: {
              services.comin = {
                enable = true;
                remotes = [
                  {
                    name = "origin";
                    url = "https://codeberg.org/aca/nix-config.git";
                    branches.main.name = "main";
                    poller.period = 10;
                  }
                ];
              };
            }
          )
        ];
      };

      nixosConfigurations.oci-xnzm-001 = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          inputs.comin.nixosModules.comin
          ./all.configuration.nix
          ./oci-xnzm-001.configuration.nix
          agenix.nixosModules.default
          (
            {...}: {
              services.comin = {
                enable = true;
                remotes = [
                  {
                    name = "origin";
                    url = "https://codeberg.org/aca/nix-config.git";
                    branches.main.name = "main";
                    poller.period = 10;
                  }
                ];
              };
            }
          )
        ];
      };

      nixosConfigurations.oci-xnzm-002 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          ./oci-xnzm-002.configuration.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.oci-xnzm-003 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          ./oci-xnzm-003.configuration.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.oci-xnzm-004 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          ./oci-xnzm-004.configuration.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.oci-aca-002 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          ./oci-aca-002.configuration.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.oci-aca-003 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          ./oci-aca-003.configuration.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.rok-chatreey-t8 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          (
            {
              config,
              pkgs,
              ...
            }: {
              nixpkgs.overlays = overlays_default system;
            }
          )

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
            (
              {
                config,
                pkgs,
                ...
              }: {
                nixpkgs.overlays = overlays_default system;
              }
            )

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
        specialArgs = {inherit inputs system;};
        modules = [
          ./all.configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.x86_64-linux.default
              inputs.elvish.packages.x86_64-linux.default
              # inputs.farchive.packages.x86_64-linux.default
              # inputs.xbox.packages.aarch64-linux.diff2
            ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./archive-0.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "~";
          }
          ./archive-0.configuration.nix
        ];
      };

      nixosConfigurations.seedbox = let
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
            (
              {
                config,
                pkgs,
                ...
              }: {
                nixpkgs.overlays = overlays_default system;
              }
            )

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
              home-manager.users.rok = import ./seedbox.home-manager.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
            ./seedbox.configuration.nix
          ];
        };
    };
}
