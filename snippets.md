
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

      # useunstable = system: pkg: { ${pkg} = nixpkgs-unstable.legacyPackages.${system}.${pkg}; };
      # useunstableoverlay =
      #   system: pkg: (final: prev: { ${pkg} = nixpkgs-unstable.legacyPackages.${system}.${pkg}; });
      # usefixed = system: pkg: { ${pkg} = nixpkgs-fixed.legacyPackages.${system}.${pkg}; };

      # (final: prev: {
      #   unstable = import nixpkgs-unstable {
      #     system = system;
      #     config.allowUnfree = true;
      #   };
      # })
