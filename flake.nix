{
  inputs = {
    # curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r '.data.result[] | select(.metric.channel=="nixos-25.11") | .metric.revision'
    # nixpkgs.url = "github:nixos/nixpkgs/25.11"'
    nixpkgs.url = "github:nixos/nixpkgs?rev=fa56d7d6de78f5a7f997b0ea2bc6efd5868ad9e8";
    # nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel?rev=d3effe14f53e61ad778d7478eeb83a97d9dd8143";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kata = {
      url = "github:aca/kata/main?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop.url = "github:aaddrick/claude-desktop-debian";

    qwer = {
      # url = "https://flakehub.com/f/aca/qwer/0";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:aca/qwer/main?shallow=1";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master?shallow=1";
    glide-browser.url = "github:glide-browser/glide.nix/main?shallow=1";

    # NOTES: check https://status.nixos.org/ and specify the revision for cache
    # TODO: reduce disk size with archived packages
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs?rev=4bdac60bfe32c41103ae500ddf894c258291dd61";
    # nixpkgs-24-05.url = "github:nixos/nixpkgs/24.05";
    # nixpkgs-24-11.url = "github:nixos/nixpkgs?rev=840dc890e9a3bba40e5a963c318ea4961c2b97f9";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs?rev=f675531bc7e6657c10a18b565cfebd8aa9e24c14";
    # nixpkgs-nightly.url = "github:NixOS/nixpkgs?rev=f675531bc7e6657c10a18b565cfebd8aa9e24c14";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master?shallow=1";
    nixpkgs-nightly.url = "github:NixOS/nixpkgs/master?shallow=1";
    nix-alien.url = "github:thiagokokada/nix-alien";
    # nixpkgs-aca.url = "github:aca/nixpkgs/master";

    nix-weather = {
      url = "github:cafkafk/nix-weather?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # url = "github:A-jay98/nix-darwin/launchAgent-cleanup";
    darwin = {
      # https://github.com/nix-darwin/nix-darwin/tree/nix-darwin-25.11?tab=readme-ov-file
      # url = "github:nix-darwin/nix-darwin/master?shallow=1";
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    mac-app-util = {
      # mac-app-util --  mktrampoline (which somescript.sh) ~/Applications/somescript.app
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ragenix = {
    #   # https://github.com/yaxitech/ragenix/blob/main/flake.nix
    #   url = "github:yaxitech/ragenix/main";
    #   # url = "github:ryantm/agenix";
    # };

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

    tmux-remote = {
      url = "github:danyim/tmux-remote/master";
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

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    templ = {
      url = "github:a-h/templ";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elvish = {
      url = "github:aca/elvish/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      # url = "github:neovim/neovim?rev=be8969f4cc1f766386319ee3dc45f6002f51713b";
      # url = "github:neovim/neovim?rev=3a4a7a7efb2769d386d780aa79b1f625a0e83ce9";
      url = "github:neovim/neovim/master";
      flake = false;
    };

    # neovim-debug = {
    #   url = "github:neovim/neovim?rev=3a4a7a7efb2769d386d780aa79b1f625a0e83ce9";
    #   flake = false;
    # };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust toolchains and rust-analyzer nightly for Nix
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nur,
      nixpkgs-unstable,
      nixpkgs-nightly,
      home-manager,
      agenix,
      dotfiles,
      zig,
      zls,
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
                  # inputs.nur.overlays.default
                  # inputs.nixpkgs-firefox-darwin.overlay
                  # (useunstableoverlay system "yabai")
                  # (useunstableoverlay system "skhd")
                ];
              }
            )

            {
              environment.systemPackages = [
                inputs.qwer.packages.${system}.default
                inputs.kata.packages.${system}.default
                # inputs.zapret.packages.x86_64-linux.default
                # inputs.zen-browser.packages.${system}.twilight-official
                # inputs.ghostty.packages.${system}.default
                # inputs.zen-browser.packages."${system}".default
                inputs.glide-browser.packages.${system}.default
                inputs.agenix.packages.${system}.default
              ];
            }

            ./txxx.configuration.nix
            ./neovim.nix
            home-manager.darwinModules.home-manager
            {
              # home-manager.sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = import ./txxx.home-manager.nix;
              home-manager.extraSpecialArgs = specialArgs;
              users.users."${username}".home = "/Users/${username}";
              nixpkgs.overlays = [
                inputs.nur.overlays.default
                # inputs.nixpkgs-firefox-darwin.overlay
                # (overlay-unstable "x86_64-linux")
                # emacs-overlay.overlay
                # nixpkgs-f2k.overlays.window-managers
              ];
            }
          ];
        };

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
      # curl https://raw.githubusercontent.com/SuperSandro2000/nixos-infect/boot-efi/nixos-infect | NIX_CHANNEL=nixos-24.11 sudo -E bash -x
      nixosConfigurations.oci-aca-001 = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system self; };
        modules = [
          ./all.configuration.nix
          ./overlay.nix

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
          #         {
          #           name = "codeberg";
          #           url = "https://codeberg.org/aca/nix-config.git";
          #           branches.main.name = "main";
          #           poller.period = 300;
          #         }
          #         # {
          #         #   name = "github";
          #         #   url = "https://github.com/aca/nix-config.git";
          #         #   branches.main.name = "main";
          #         #   poller.period = 30;
          #         # }
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

          (
            {
              config,
              pkgs,
              ...
            }:
            {
              nixpkgs.overlays = [
                inputs.nix-cachyos-kernel.overlays.pinned
              ];

              boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-rc-lto;
              nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
              nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
            }
          )

          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              (import ./pkgs/vifm/vifmrc.nix)
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./sm-a556e.home-manager.nix;
            home-manager.extraSpecialArgs = { inherit self inputs; };
            home-manager.backupFileExtension = "bak";
          }

          {
            environment.systemPackages = [
              # inputs.zen-browser.packages.${system}.twilight-official
              # inputs.zen-browser.packages."${system}".default
              inputs.agenix.packages.${system}.default
              inputs.glide-browser.packages.${system}.default
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
          # "${inputs.nixpkgs-unstable}/nixos/modules/services/cluster/temporal/default.nix"
          ./all.configuration.nix
          ./overlay.nix
          agenix.nixosModules.default
          ./home.configuration.nix
          ./neovim.nix
          # inputs.zen-browser.packages.${system}.twilight-official

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
              inputs.qwer.packages.${system}.default
              inputs.glide-browser.packages.${system}.default
              # inputs.lightpanda.packages.${system}.default
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
        # system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          # system = "x86_64-linux";
        };
        # specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./overlay.nix
          ./overlay2.nix
          inputs.agenix.nixosModules.default
          ./root.configuration.nix
          ./neovim.nix
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./root.home-manager.nix;
            home-manager.users.root =
              { pkgs, ... }:
              {
                home.stateVersion = "25.11";
              };
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "bak";
            home-manager.sharedModules = [ (import ./pkgs/vifm/vifmrc.nix) ];
          }

          (
            {
              pkgs,
              inputs,
              ...
            }:
            {
              environment.systemPackages = [
                # inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.nil
                agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];
            }
          )

          # {
          #   environment.systemPackages = [
          #     # elvish
          #     # inputs.elvish.packages.x86_64-linux.default
          #     agenix.packages.${stdenv.hostPlatform.system}.default
          #     # inputs.ghostty.packages.x86_64-linux.default
          #     # inputs.watchrun.packages.x86_64-linux.default
          #     # inputs.ghostty.packages.x86_64-linux.default
          #     # inputs.templ.packages.x86_64-linux.default
          #     # inputs.fh.packages.x86_64-linux.default
          #     # zig.packages.x86_64-linux.master
          #     # inputs.zls.packages.x86_64-linux.default
          #     # inputs.nixpkgs-zig-0-12.legacyPackages.x86_64-linux.zig_0_12
          #     # inputs.alacritty.defaultPackage.x86_64-linux
          #     # turbo.packages.x86_64-linux.default
          #   ];
          # }
        ];
      };

      nixosConfigurations.oci-jkor = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./oci-jkor.configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rok = import ./oci-jkor.home-manager.nix;
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
      nixosConfigurations.seedbox-impx = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          # inputs.comin.nixosModules.comin
          ./all.configuration.nix
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

      nixosConfigurations.tsvm = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs system; };
        modules = [
          ./all.configuration.nix
          ./overlay.nix
          ./tsvm.configuration.nix
          ./neovim.nix
          agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."rok" = import ./tsvm.home-manager.nix;
            home-manager.users.root =
              { pkgs, ... }:
              {
                home.stateVersion = "25.11";
              };
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

          (
            {
              config,
              pkgs,
              ...
            }:
            {
              nixpkgs.overlays = [
                inputs.nix-cachyos-kernel.overlays.pinned
              ];

              boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server;
              nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
              nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
            }
          )
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

          (
            {
              config,
              pkgs,
              ...
            }:
            {
              nixpkgs.overlays = [
                inputs.nix-cachyos-kernel.overlays.pinned
              ];

              boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server;
              nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
              nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
            }
          )
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
              agenix.packages.${system}.default
              # inputs.elvish.packages.${system}.default
              # inputs.farchive.packages.x86_64-linux.default
              # inputs.xbox.packages.aarch64-linux.diff2
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              (import ./pkgs/vifm/vifmrc.nix)
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.root =
              { pkgs, ... }:
              {
                home.stateVersion = "25.11";
              };
            home-manager.users.rok = import ./archive-0.home-manager.nix;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "~";
          }
          ./archive-0.configuration.nix
        ];
      };
    };
}
