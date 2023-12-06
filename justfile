switch options='':
    #!/usr/bin/env bash
    case "$(hostname -s)" in

      *chung02)
        nix run nix-darwin -- switch --flake '.#rok-toss' --impure {{options}}
        ;;

      *)
        sudo nixos-rebuild switch --flake ".#$(hostname -s)" --impure {{options}}
        ;;

    esac
    
upgrade:
    #!/usr/bin/env bash
    nix flake update
    just switch --upgrade
    # sudo nixos-rebuild switch --flake ".#$(hostname -s)" --impure --upgrade
    # nix run nix-darwin -- switch --flake '.#rok-toss'
