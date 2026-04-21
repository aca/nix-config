# qwer

## deploy

```bash
set -x
export NIXPKGS_ALLOW_INSECURE=1
TARGET=$1
FLAKE=${2:-$1}
# nixos-rebuild switch --sudo --option allow-unsafe-native-code-during-evaluation true --verbose --no-reexec --impure --flake ".#$FLAKE" --target-host "root@$TARGET" --build-host "root@$TARGET"
nixos-rebuild switch --sudo --option allow-unsafe-native-code-during-evaluation true --verbose --no-reexec --impure --flake ".#$FLAKE" --target-host "root@$TARGET"
```

## deploy2

```bash
export NIXPKGS_ALLOW_INSECURE=1
TARGET=${2:-$1}
set -euxo pipefail
git push || true
ssh -t root@$TARGET 'cd /home/rok/src/git.internal/nix-config && git reset --hard && git pull --rebase && nix --extra-experimental-features "nix-command flakes" run github:aca/qwer/main -- switch'
```

## switch

```bash
FLAKE=${1:-$(hostname)}
case "$FLAKE" in
elckyung*|"Mac"*)
    FLAKE="txxx"
    sudo nix --extra-experimental-features 'nix-command flakes' --option allow-unsafe-native-code-during-evaluation true run -- nix-darwin switch --verbose --flake ".#${FLAKE}" --impure "$@"
    ;;
* )
    sudo NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --option build-use-sandbox relaxed --option allow-unsafe-native-code-during-evaluation true  --flake ".#${FLAKE}" --impure 2>&1 | tee /tmp/rebuild.log.$(date +%Y%m%dT%H%M%S)
    ;;
esac
```


## update
```bash
set -euxo pipefail

git subrepo pull --all

export NIXPKGS_ALLOW_INSECURE=1
nix flake update
release="nixos-25.11"
nix --extra-experimental-features 'nix-command flakes' flake lock --override-input nixpkgs-unstable github:NixOS/nixpkgs/$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"nixpkgs-unstable\") | .metric.revision")
nix --extra-experimental-features 'nix-command flakes' flake lock --override-input nixpkgs-nightly github:NixOS/nixpkgs/$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"nixpkgs-nightly\") | .metric.revision")
```

## update-flake
```bash
set -euxo pipefail
export NIXPKGS_ALLOW_INSECURE=1
nix eval --impure --json --expr 'builtins.attrNames (builtins.getFlake (toString ./.)).inputs' | jq -r '.[]' | fzf | xargs nix --extra-experimental-features 'nix-command flakes' flake lock --update-input 
```

## daily
```bash
set -euxo pipefail
export NIXPKGS_ALLOW_INSECURE=1
nix --extra-experimental-features 'nix-command flakes' flake lock --update-input glide-browser
nix --extra-experimental-features 'nix-command flakes' flake lock --update-input kata
nix --extra-experimental-features 'nix-command flakes' flake lock --update-input qwer
nix --extra-experimental-features 'nix-command flakes' flake lock --update-input dotfiles
nix --extra-experimental-features 'nix-command flakes' flake lock --update-input elvish
```

## qwer
```bash
#!/usr/bin/env bash
set -euxo pipefail

export NIXPKGS_ALLOW_INSECURE=1
nix --extra-experimental-features 'nix-command flakes' flake lock --update-input $1
# nix flake update --commit-lock-file
```
