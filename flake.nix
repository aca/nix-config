# https://ayats.org/blog/no-home-anager
{
  inputs = {



    # pyproject-nix = {
    #   url = "github:pyproject-nix/pyproject.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # uv2nix = {
    #   url = "github:pyproject-nix/uv2nix";
    #   inputs.pyproject-nix.follows = "pyproject-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # pyproject-build-systems = {
    #   url = "github:pyproject-nix/build-system-pkgs";
    #   inputs.pyproject-nix.follows = "pyproject-nix";
    #   inputs.uv2nix.follows = "uv2nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # NOTES: check https://status.nixos.org/ and specify the revision for cache
    # TODO: reduce disk size with archived packages
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs?rev=f675531bc7e6657c10a18b565cfebd8aa9e24c14";
    # nixpkgs-nightly.url = "github:NixOS/nixpkgs?rev=f675531bc7e6657c10a18b565cfebd8aa9e24c14";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    nixpkgs-nightly.url = "github:NixOS/nixpkgs/master";
    nix-alien.url = "github:thiagokokada/nix-alien";
    # nixpkgs-aca.url = "github:aca/nixpkgs/master";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rgit = {
      url = "github:w4/rgit";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
    };

    # mac-app-util --  mktrampoline (which somescript.sh) ~/Applications/somescript.app
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kata = {
      url = "github:aca/kata/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
    };

    # flake-utils = {
    #   url = "github:numtide/flake-utils";
    # };

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "git+https://codeberg.org/aca/dotfiles?submodules=0";
      flake = false;
    };

    elvish-edit-elv = {
      url = "github:xiaq/edit.elv/master";
      flake = false;
    };

    elvish-utils = {
      url = "github:aca/elvish-utils/main";
      flake = false;
    };

    sway-workspace = {
      url = "github:matejc/sway-workspace/master";
      flake = false;
    };

    # vtsls = {
    #   url = "github:yioneko/vtsls/main";
    #   flake = false;
    # };

    ghostty = {
      # url = "github:ghostty-org/ghostty/main";
      url = "github:ghostty-org/ghostty/main";
      # inputs.nixpkgs-stable.follows = "nixpkgs";
      # inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };

    templ = {
      url = "github:a-h/templ";
    };

    # watchrun.url = "github:aca/watchrun/main";
    # farchive.url = "github:aca/farchive/main";

    elvish = {
      url = "github:aca/elvish/master";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    zig = {
      url = "github:mitchellh/zig-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      # url = "github:neovim/neovim?rev=3cdb84e0c694e9f321dbe41c1111d0846c1beb03";
      url = "github:neovim/neovim/master";
      flake = false;
    };

    # turbo.url = "github:alexghr/turborepo.nix";

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust toolchains and rust-analyzer nightly for Nix
    fenix = {
      url = "github:nix-community/fenix";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      # vaultix,
      nur,
      nixpkgs-unstable,
      nixpkgs-nightly,
      home-manager,
      agenix,
      dotfiles,
      mac-app-util,
      zig,
      zls,
      darwin,
      uv2nix,
      pyproject-nix,
      pyproject-build-systems,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
    in
    {
      darwinConfigurations.txxx =
        let
          username = "kyungrok.chung";
          system = "aarch64-darwin";
        in
        inputs.darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs system; };
          modules = [
            # ./all.configuration.nix
            ./overlay.nix
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                nixpkgs.overlays = [
                  inputs.nur.overlays.default
                  inputs.nixpkgs-firefox-darwin.overlay
                  # (useunstableoverlay system "yabai")
                  # (useunstableoverlay system "skhd")
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
              home-manager.sharedModules = [ mac-app-util.homeManagerModules.default ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = import ./txxx.home-manager.nix;
              home-manager.extraSpecialArgs = specialArgs;
              users.users."${username}".home = "/Users/${username}";
            }
          ];
        };

      nixosConfigurations.tsvm = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs self system; };
        modules = [
          # (
          # )
          ./all.configuration.nix
          # ./linux.configuration.nix
          ./neovim.nix
          ./overlay.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              inputs.agenix.packages.${system}.default
              # inputs.zen-browser.packages.aarch64-linux.twilight-official
              # inputs.ghostty.packages.${system}.default
              # zig
              # inputs.lazybox.packages.aarch64-linux.xxx2
              # inputs.nixpkgs-zig-0-12.legacyPackages.aarch64-linux.zig_0_12
              # inputs.zls.packages.aarch64-linux.default
            ];
          }
          ./tsvm.configuration.nix
          home-manager.nixosModules.home-manager
          {
            # https://github.com/nix-community/home-manager/issues/1698
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./tsvm.home-manager.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.backupFileExtension = "bak";
          }
        ];
      };
      #
      # # home-manager switch switch --flake '.#rok@txxx-nix'
      # homeConfigurations."rok@txxx-nix" =
      #   let
      #     system = "aarch64-linux";
      #   in
      #   home-manager.lib.homeManagerConfiguration rec {
      #     pkgs = nixpkgs.legacyPackages.${system};
      #     extraSpecialArgs = { inherit inputs; };
      #     modules = [
      #       ./txxx-nix.home-manager.nix
      #       {
      #         nixpkgs.overlays = [
      #           inputs.nur.overlays.default
      #         ];
      #       }
      #     ];
      #   };

      homeConfigurations."rok@home" =
        let
        in
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          # sharedModules = [
          #   (import ./pkgs/vifm/vifmrc.nix)
          # ];
          modules = [
            ./home.home-manager.nix
            {
              nixpkgs.overlays = [
                # (overlay-unstable "x86_64-linux")
                inputs.nur.overlays.default
                # emacs-overlay.overlay
                # nixpkgs-f2k.overlays.window-managers
              ];
            }
          ];
        };

      #
      # # home-manager switch switch --flake '.#rok@home'
      # homeConfigurations."rok@root" =
      #   let
      #   in
      #   home-manager.lib.homeManagerConfiguration rec {
      #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #     extraSpecialArgs = { inherit inputs; };
      #     modules = [
      #       ./root.home-manager.nix
      #       {
      #         nixpkgs.overlays = [
      #           # (overlay-unstable "x86_64-linux")
      #           inputs.nur.overlays.default
      #           # emacs-overlay.overlay
      #           # nixpkgs-f2k.overlays.window-managers
      #         ];
      #       }
      #     ];
      #   };
      #
      # # .#oci-aca-001
      nixosConfigurations.oci-aca-001 = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system self; };
        modules = [
          ./all.configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              inputs.agenix.packages.${system}.default
            ];
          }
          ./oci-aca-001.configuration.nix

          # inputs.comin.nixosModules.comin
          # (
          #   { ... }:
          #   {
          #     services.comin = {
          #       enable = true;
          #       remotes = [
          #         # {
          #         #   name = "codeberg";
          #         #   url = "https://codeberg.org/aca/nix-config.git";
          #         #   branches.main.name = "main";
          #         #   poller.period = 30;
          #         # }
          #         {
          #           name = "github";
          #           url = "https://github.com/aca/nix-config.git";
          #           branches.main.name = "main";
          #           poller.period = 30;
          #         }
          #       ];
          #     };
          #   }
          # )
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

      nixosConfigurations.sm-a556e = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./overlay.nix
          agenix.nixosModules.default
          ./sm-a556e.configuration.nix
          ./neovim.nix

          home-manager.nixosModules.home-manager
          {
            # home-manager.sharedModules = [
            #   (import ./pkgs/vifm/vifmrc.nix)
            # ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./sm-a556e.home-manager.nix;
            home-manager.extraSpecialArgs = { inherit self inputs; };
            home-manager.backupFileExtension = "bak";
          }

          {
            environment.systemPackages = [
              # inputs.zapret.packages.x86_64-linux.default
              # inputs.zen-browser.packages.${system}.twilight-official
              # inputs.ghostty.packages.x86_64-linux.default
              # inputs.zen-browser.packages."${system}".default
              inputs.agenix.packages.${system}.default
              inputs.ghostty.packages.${system}.default
              # inputs.neovim.packages.${system}.default
            ];
          }
        ];
      };

      # .#home
      nixosConfigurations.home = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./overlay.nix
          agenix.nixosModules.default
          ./home.configuration.nix
          ./neovim.nix
          # inputs.zen-browser.packages.${system}.twilight-official

          # rgit.nixosModules.${system}.default
          # {
          #   services.rgit = {
          #     enable = true;
          #     bindAddress = "[::]:3333";
          #     dbStorePath = "/tmp/rgit.db";
          #     repositoryStorePath = "/home/rok/src/git.internal";
          #   };
          # }

          home-manager.nixosModules.home-manager
          {
            # home-manager.sharedModules = [
            #   (import ./pkgs/vifm/vifmrc.nix)
            # ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./home.home-manager.nix;
            home-manager.extraSpecialArgs = { inherit self inputs; };
            home-manager.backupFileExtension = "bak";
          }

          {
            environment.systemPackages = [
              # inputs.zapret.packages.x86_64-linux.default
              # inputs.zen-browser.packages.${system}.twilight-official
              inputs.ghostty.packages.x86_64-linux.default
              # inputs.zen-browser.packages."${system}".default
              inputs.agenix.packages.x86_64-linux.default
              # inputs.neovim.packages.${system}.default
            ];
          }
        ];
      };

      # # .#root
      nixosConfigurations.root = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          agenix.nixosModules.default
          ./root.configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./root.home-manager.nix;
            home-manager.users.root =
              { pkgs, ... }:
              {
                home.stateVersion = "25.05";
              };
            # home-manager.users.tmp =
            #   { pkgs, ... }:
            #   {
            #     home.stateVersion = "25.05";
            #   };
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "bak";
            home-manager.sharedModules = [ (import ./pkgs/vifm/vifmrc.nix) ];
          }

          # {
          #   services.rgit = {
          #     enable = true;
          #     bindAddress = "[::]:3333";
          #     dbStorePath = "/tmp/rgit.db";
          #     repositoryStorePath = "/home/rok/src/git.internal";
          #   };
          # }

          {
            environment.systemPackages = [
              # elvish
              # inputs.elvish.packages.x86_64-linux.default
              agenix.packages.x86_64-linux.default
              # inputs.ghostty.packages.x86_64-linux.default
              # inputs.watchrun.packages.x86_64-linux.default
              # inputs.ghostty.packages.x86_64-linux.default
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
      #
      nixosConfigurations.seedbox-impx = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          inputs.comin.nixosModules.comin
          ./all.configuration.nix
          ./log.nix
          ./seedbox-impx.configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./seedbox-impx.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "bak";
          }
          agenix.nixosModules.default
          # (
          #   { ... }:
          #   {
          #     services.comin = {
          #       enable = true;
          #       remotes = [
          #         {
          #           name = "origin";
          #           url = "https://codeberg.org/aca/nix-config.git";
          #           branches.main.name = "main";
          #           poller.period = 10;
          #         }
          #       ];
          #     };
          #   }
          # )
        ];
      };
      #
      # nixosConfigurations.oci-impx-003 = nixpkgs.lib.nixosSystem rec {
      #   system = "x86_64-linux";
      #   specialArgs = { inherit inputs system; };
      #   modules = [
      #     inputs.comin.nixosModules.comin
      #     ./all.configuration.nix
      #     ./oci-impx-003.configuration.nix
      #     agenix.nixosModules.default
      #     (
      #       { ... }:
      #       {
      #         services.comin = {
      #           enable = true;
      #           remotes = [
      #             {
      #               name = "origin";
      #               url = "https://codeberg.org/aca/nix-config.git";
      #               branches.main.name = "main";
      #               poller.period = 10;
      #             }
      #           ];
      #         };
      #       }
      #     )
      #   ];
      # };
      #

      nixosConfigurations.seedbox = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./seedbox.configuration.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.txxx-orb = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./txxx-orb.configuration.nix
          agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."kyungrok.chung" = import ./txxx-orb.home-manager.nix;
            home-manager.users.root =
              { pkgs, ... }:
              {
                home.stateVersion = "25.05";
              };
            # home-manager.users.tmp =
            #   { pkgs, ... }:
            #   {
            #     home.stateVersion = "25.05";
            #   };
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "bak";
          }

        ];

      };

      #
      # nixosConfigurations.oci-xnzm-002 = nixpkgs.lib.nixosSystem rec {
      #   system = "x86_64-linux";
      #   specialArgs = { inherit inputs system; };
      #   modules = [
      #     ./all.configuration.nix
      #     ./oci-xnzm-002.configuration.nix
      #     agenix.nixosModules.default
      #   ];
      # };
      #
      # nixosConfigurations.oci-xnzm-003 = nixpkgs.lib.nixosSystem rec {
      #   system = "x86_64-linux";
      #   specialArgs = { inherit inputs system; };
      #   modules = [
      #     ./all.configuration.nix
      #     ./oci-xnzm-003.configuration.nix
      #     agenix.nixosModules.default
      #   ];
      # };
      #

      nixosConfigurations.oci-aca-002 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./overlay.nix
          ./oci-aca-002.configuration.nix
          agenix.nixosModules.default
        ];
      };


      nixosConfigurations.oci-aca-003 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./overlay.nix
          ./oci-aca-003.configuration.nix
          agenix.nixosModules.default
        ];
      };


      nixosConfigurations.archive-0 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system; };
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
    };
}
