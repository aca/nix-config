# qwer

## deploy

```bash
set -x
export NIXPKGS_ALLOW_INSECURE=1
TARGET=$1
FLAKE=${2:-$1}
# nixos-rebuild switch --sudo --option allow-unsafe-native-code-during-evaluation true --verbose --no-reexec --impure --flake ".#$FLAKE" --target-host "root@$TARGET" --build-host "root@$TARGET"
nixos-rebuild switch --sudo --option allow-unsafe-native-code-during-evaluation true --verbose --no-reexec --impure --flake ".#$FLAKE" --target-host "root@$TARGET"
# nixos-rebuild boot --sudo --option allow-unsafe-native-code-during-evaluation true --verbose --no-reexec --impure --flake ".#$FLAKE" --target-host "root@$TARGET"
```

## deploy2

```bash
set -euxo pipefail
set -euxo pipefail
export NIXPKGS_ALLOW_INSECURE=1
FLAKE="$1"
NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --option build-use-sandbox relaxed --option allow-unsafe-native-code-during-evaluation true  --flake ".#${FLAKE}" --impure --target-host "root@$FLAKE" --build-host "root@$FLAKE"
```

<!-- # ssh -t root@$TARGET 'cd /home/rok/src/git.internal/nix-config && git reset --hard && git pull --rebase && git submodule sync && nix --extra-experimental-features "nix-command flakes" run github:aca/qwer/main -- switch' -->

## build

switch 전에 빌드만 검증. 결과 토플레벨을 `./result` 심볼릭 링크로 남김.

```bash
FLAKE=${1:-$(hostname)}
case "$FLAKE" in
elckyung*|"Mac"*)
    FLAKE="txxx"
    nix --extra-experimental-features 'nix-command flakes' build --impure ".#darwinConfigurations.${FLAKE}.system"
    ;;
* )
    NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features 'nix-command flakes' build --impure --option allow-unsafe-native-code-during-evaluation true ".#nixosConfigurations.${FLAKE}.config.system.build.toplevel"
    ;;
esac
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
# nix flake update elvish --option access-tokens "github.com=$(gh auth token)"
nix flake update --option access-tokens "github.com=$(gh auth token)"
release="nixos-26.05"
nix --extra-experimental-features 'nix-command flakes' flake lock --option access-tokens "github.com=$(gh auth token)" --override-input nixpkgs github:NixOS/nixpkgs/$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"$release\") | .metric.revision")
nix --extra-experimental-features 'nix-command flakes' flake lock --option access-tokens "github.com=$(gh auth token)" --override-input nixpkgs-unstable github:NixOS/nixpkgs/$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"nixpkgs-unstable\") | .metric.revision")
nix --extra-experimental-features 'nix-command flakes' flake lock --option access-tokens "github.com=$(gh auth token)" --override-input nixpkgs-nightly github:NixOS/nixpkgs/$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"nixpkgs-unstable\") | .metric.revision")
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
# nix --extra-experimental-features 'nix-command flakes' flake lock --update-input glide-browser
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

## diagnose

전체 진단을 한 번에. plain vs host vs 채널 비교.

```bash
PKG=${1:-xpra}
HOST=${2:-seedbox}
SYS=x86_64-linux

echo "## locked nixpkgs rev"
LOCKED=$(nix --extra-experimental-features 'nix-command flakes' flake metadata --json | jq -r '.locks.nodes.nixpkgs.locked.rev')
CHANNEL=$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r '.data.result[] | select(.metric.channel=="nixos-25.11") | .metric.revision')
echo "locked : $LOCKED"
echo "channel: $CHANNEL"
[ "$LOCKED" = "$CHANNEL" ] && echo "=> 채널 최신" || echo "=> 채널과 다름 (오래됐거나 브랜치 HEAD)"

chk() { H=$(basename "$1"|cut -d- -f1); C=$(curl -s -o /dev/null -w "%{http_code}" "https://cache.nixos.org/${H}.narinfo"); echo "$1 -> $C ($([ "$C" = 200 ] && echo HIT || echo MISS))"; }

echo; echo "## plain locked nixpkgs $PKG (overlay 미적용)"
chk "$(nix eval --raw --impure --expr "(builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${SYS}.${PKG}.outPath")"

echo; echo "## $HOST host $PKG (overlay.nix 적용, 배포 실제 대상)"
chk "$(nix --extra-experimental-features 'nix-command flakes' eval --impure --raw ".#nixosConfigurations.${HOST}.pkgs.${PKG}.outPath")"

echo
echo "해석:"
echo "- plain HIT & host MISS  => overlay.nix가 클로저 변형 (정상, 불가피한 캐시 미스)"
echo "- plain MISS & host MISS => 채널 revision에서 Hydra 미빌드 => qwer update 재실행"
echo "- 둘 다 HIT              => 캐시 정상, 다른 원인"
```

