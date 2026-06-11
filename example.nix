{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, android-nixpkgs }: {

    nixosConfigurations.x86_64-linux.myhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager

        {
          home-manager.users.myusername = { config, lib, pkgs, ... }: {
            imports = [
              android-nixpkgs.hmModule

              {
                inherit config lib pkgs;
                android-sdk.enable = true;

                # Optional; default path is "~/.local/share/android".
                android-sdk.path = "${config.home.homeDirectory}/.android/sdk";

                android-sdk.packages = sdk: with sdk; [
                  build-tools-34-0-0
                  cmdline-tools-latest
                  emulator
                  platforms-android-34
                  sources-android-34
                ];
              }
            ];
          };
        }
      ];
    };
  };
}
