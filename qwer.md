# qwer

## deploy

```bash
set -x
export NIXPKGS_ALLOW_INSECURE=1
TARGET=${1#root@}
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
    NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features 'nix-command flakes' build --impure --option allow-unsafe-native-code-during-evaluation true ".#nixosConfigurations.${FLAKE}.config.system.build.toplevel" --option extra-substituters "https://attic.xuyh0120.win/lantian" --option extra-trusted-public-keys "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
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
tscm)
    sudo NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --option build-use-sandbox relaxed --option allow-unsafe-native-code-during-evaluation true --no-reexec --flake ".#${FLAKE}" --impure  --option extra-substituters "https://attic.xuyh0120.win/lantian" --option extra-trusted-public-keys "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" 2>&1 | tee /tmp/rebuild.log.$(date +%Y%m%dT%H%M%S)
    ;;
* )
    sudo NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --option build-use-sandbox relaxed --option allow-unsafe-native-code-during-evaluation true  --flake ".#${FLAKE}" --impure  --option extra-substituters "https://attic.xuyh0120.win/lantian" --option extra-trusted-public-keys "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" 2>&1 | tee /tmp/rebuild.log.$(date +%Y%m%dT%H%M%S)
    ;;

esac
```


## boot

```bash
FLAKE=${1:-$(hostname)}
case "$FLAKE" in
elckyung*|"Mac"*)
    FLAKE="txxx"
    sudo nix --extra-experimental-features 'nix-command flakes' --option allow-unsafe-native-code-during-evaluation true run -- nix-darwin switch --verbose --flake ".#${FLAKE}" --impure "$@"
    ;;
* )
    sudo NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild boot --option build-use-sandbox relaxed --option allow-unsafe-native-code-during-evaluation true  --flake ".#${FLAKE}" --impure 2>&1 | tee /tmp/rebuild.log.$(date +%Y%m%dT%H%M%S)
    ;;
esac
```


## update
```bash
set -euxo pipefail

git subrepo pull --all || true

export NIXPKGS_ALLOW_INSECURE=1
# flake.nix 입력 url 이 채널 브랜치를 가리킴:
#   nixpkgs          -> nixos-26.05        (Hydra 빌드+캐시 완료된 채널 head)
#   nixpkgs-unstable -> nixpkgs-unstable   (빌드 있는 최신, 항상 캐시됨)
#   nixpkgs-nightly  -> master             (최신, 캐시 보장 X / 사실상 미사용)
# 따라서 flake update 만 하면 각 채널 head 로 고정된다.
nix --extra-experimental-features 'nix-command flakes' flake update nixpkgs nixpkgs-unstable nixpkgs-nightly --option access-tokens "github.com=$(gh auth token)"

# fallback: url 대신 monitoring.nixos.org 의 채널 revision 으로 직접 고정하고 싶을 때
# release="nixos-26.05"
# nix --extra-experimental-features 'nix-command flakes' flake lock --option access-tokens "github.com=$(gh auth token)" --override-input nixpkgs github:NixOS/nixpkgs/$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"$release\") | .metric.revision")
# nix --extra-experimental-features 'nix-command flakes' flake lock --option access-tokens "github.com=$(gh auth token)" --override-input nixpkgs-unstable github:NixOS/nixpkgs/$(curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"nixpkgs-unstable\") | .metric.revision")
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

## dry-build

`qwer switch` 가 느릴 때, 실제로 무엇을 **소스 빌드**하고 무엇을 **캐시에서 받는지** 미리 실측한다.
switch 와 동일 조건(substituter = cache.nixos.org + lantian, root = 신뢰 사용자)으로 돌리되 아무것도 만들지 않는다.

```bash
FLAKE=${1:-$(hostname)}
NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 \
sudo NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 \
  nixos-rebuild dry-build --flake ".#${FLAKE}" --impure \
  --option allow-unsafe-native-code-during-evaluation true \
  --option extra-substituters "https://attic.xuyh0120.win/lantian" \
  --option extra-trusted-public-keys "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" 2>&1 | tee /tmp/drybuild.txt
```

해석:
- `will be built`  = 어떤 캐시에도 없어 **소스 컴파일**할 대상 (unfree·overlay·미캐시 리비전 등 → 느림의 원인)
- `will be fetched` = 캐시에서 다운로드 (정상. flake update 후 버전 바뀌면 일시적으로 큼)
- 단, `sudo` 가 아니면 lantian 이 무시되니(`rok` 비신뢰) 반드시 sudo 로.

`will be built` 에는 system-unit/wrapper 류 즉시 생성 노이즈가 많다. 실제 패키지만 추리려면:

```bash
awk '/will be built:/{f=1;next} /will be fetched/{f=0} f&&/\.drv$/{print}' /tmp/drybuild.txt \
 | sed -E 's#.*/[a-z0-9]+-##; s#\.drv$##' \
 | grep -vE '^(unit-|X-Restart|system-|user-|etc$|activate|boot\.json|hwdb|initrd|nixos-system|dbus-|.*-modules(-shrunk)?$|.*generators$|.*units$|.*shutdown$)' \
 | sort -u
```

개별 패키지가 어느 캐시에 있는지는 아래 `## diagnose` 로 확인한다.

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

