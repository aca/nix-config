# cache

바이너리 캐시 미스(= 패키지가 소스로 빌드됨) 진단 노트.

## 결론 (TL;DR)

`qwer deploy2 seedbox` 가 xpra 를 소스 빌드한 근본 원인 = **`overlay.nix:136-137` 의 ffmpeg useunstable**.

```nix
// (useunstable system "ffmpeg-full")
// (useunstable system "ffmpeg")
```

- lock된 nixpkgs ffmpeg = **8.0**
- nixpkgs-unstable ffmpeg = **8.0.1** ← overlay가 이걸로 교체
- 의존성 체인(nix-diff로 증명): **ffmpeg 8.0→8.0.1 ⇒ opencv 재빌드 ⇒ xpra 재빌드**
- 그 클로저는 cache.nixos.org에 없음(Hydra는 순정 nixpkgs=ffmpeg-8.0만 빌드) ⇒ 소스 빌드

xpra 자체는 overlay에서 override되지 않는다. 하지만 ffmpeg가 xpra의 전이 의존성이라 연쇄 재빌드된다.

진단 과정에서 폐기된 가설(기록용):
1. ❌ nixpkgs가 브랜치 HEAD에 lock됨 → hello/bash 캐시 테스트로 반증. lock은 정상 채널 revision.
2. ❌ 채널 revision 시점 xpra Hydra 미빌드 → 동일 플랫폼 비교 시 plain xpra는 캐시됨(200).
3. ⚠️ "overlay가 클로저를 바꾼다"까지는 맞았으나 *어떤* 의존성인지 미증명 + plain(x86_64) vs host(aarch64) 플랫폼을 혼동한 잘못된 비교를 했었음. nix-diff 동일 플랫폼 재비교로 ffmpeg로 확정.

핵심 구분 (반드시 **동일 플랫폼**으로 비교할 것 — seedbox = `aarch64-linux`):
- plain locked nixpkgs xpra (aarch64): `wfry8hli...` → cache.nixos.org **200**
- 호스트 설정(overlay 적용) xpra (aarch64): `irbc0a8989...` → cache.nixos.org **404** ← 배포 실제 대상

교훈: Hydra/cache.nixos.org는 **순정 nixpkgs**만 빌드한다. overlay의 `useunstable ffmpeg` 처럼 의존성이 깊은 패키지를 바꾸면 그걸 쓰는 모든 클로저(opencv, xpra, …)가 캐시 미스가 된다. 캐시 미스 진단 시 nix-diff로 *어떤 입력이 다른지* 끝까지 추적하고, 비교는 **같은 system** 끼리 할 것.

## 상태

해결됨. `overlay.nix` 에서 `useunstable "ffmpeg" / "ffmpeg-full"` 제거(→ `ffmpeg-full-nightly`
별도 속성으로 분리). 검증: seedbox host xpra = `wfry8hli...` → cache.nixos.org **200 HIT**,
host ffmpeg = 8.0. 소스 빌드 사라짐.

## walkthrough (재현 절차)

이 진단을 처음부터 그대로 따라하는 순서. `$HOST=seedbox`, `$PKG=xpra` 기준.

1. **배포가 정말 소스 빌드하는지 확인** — host 패키지가 캐시에 없는지:
   ```bash
   # check-cache-host 레시피
   nix eval --impure --raw ".#nixosConfigurations.seedbox.pkgs.xpra.outPath" \
     | xargs basename | cut -d- -f1 \
     | xargs -I{} curl -s -o /dev/null -w "%{http_code}\n" "https://cache.nixos.org/{}.narinfo"
   # 404 면 소스 빌드 확정
   ```

2. **lock이 채널 최신인지** — `locked-rev` vs `current-channel-rev`. 다르면 오래된 것이지
   브랜치 HEAD가 아닌지 기반 패키지로 검증:
   ```bash
   # check-cache-rev <locked-rev> hello  → 200 이면 그 rev는 정상 채널 revision (lock 문제 아님)
   ```

3. **plain vs host 비교 (반드시 동일 system!)** — host의 system을 먼저 알아내고 그 system으로 plain 평가:
   ```bash
   nix eval --raw --impure ".#nixosConfigurations.seedbox.pkgs.stdenv.hostPlatform.system"
   #  => aarch64-linux  (x86_64로 비교하면 오진!)
   # check-cache xpra aarch64-linux  → plain 200
   # check-cache-host seedbox xpra   → host  404
   # 둘이 갈리면 = overlay/config 가 클로저를 바꾼 것
   ```

4. **무엇이 다른지 nix-diff 로 추적** — `why-rebuilt` 레시피. 출력의 `named` 라인이 바뀐 입력:
   ```
   - ffmpeg-8.0
   + ffmpeg-8.0.1
   • The input derivation named `opencv-4.12.0` differs   ← ffmpeg → opencv → xpra 체인
   ```

5. **그 입력의 출처를 config에서 grep**:
   ```bash
   grep -rn "ffmpeg" overlay.nix all.configuration.nix
   #  => overlay.nix:136-137  // (useunstable system "ffmpeg" / "ffmpeg-full")
   nix eval --raw --impure --expr \
     '(builtins.getFlake (toString ./.)).inputs.nixpkgs-unstable.legacyPackages.aarch64-linux.ffmpeg.version'
   #  => 8.0.1  (lock된 nixpkgs는 8.0)  ← 원인 확정
   ```

6. **수정 후 재검증** — 1번 명령 재실행해서 200 나오는지.

## 핵심 개념

- `nix.settings.substituters` 는 *빌드 결과 시스템*의 nix.conf에 들어갈 뿐, *지금 빌드를 수행하는* nix 설정이 아니다. 새 캐시는 한 번 switch 성공 후 다음 배포부터 적용된다 (닭-달걀).
- cache.nixos.org(Hydra)는 **채널로 승격된 특정 revision의 순정 nixpkgs**만 빌드/보관한다. 브랜치 HEAD나 overlay 변형 derivation은 없다.
- Hydra는 채널 승격 시 *모든* 패키지 성공을 요구하지 않는다. 무거운 패키지(xpra: gstreamer/ffmpeg/python 다수)는 특정 revision에서 미빌드일 수 있다.
- harmonia(`seedbox-impx:5000`)는 별도 저장소가 아니라 그 호스트의 `/nix/store`를 그대로 노출할 뿐이다. 이 문제와는 무관했다.

## check-cache

현재 lock된 **순정 nixpkgs** 의 패키지가 공식 캐시에 있는지 확인. (overlay 미적용)
SYS는 비교 대상 호스트와 반드시 일치시킬 것 (seedbox=aarch64-linux). 기본값은 현재 머신.

```bash
PKG=${1:-xpra}
SYS=${2:-$(nix eval --raw --impure --expr 'builtins.currentSystem')}
OUT=$(nix eval --raw --impure --expr \
  "(builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${SYS}.${PKG}.outPath")
HASH=$(basename "$OUT" | cut -d- -f1)
CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://cache.nixos.org/${HASH}.narinfo")
echo "[$SYS] $OUT"
echo "cache.nixos.org/${HASH}.narinfo -> $CODE  ($([ "$CODE" = 200 ] && echo HIT || echo MISS))"
```

## check-cache-host

배포 때 **실제로 빌드되는** 호스트 설정(overlay.nix 적용) 패키지가 캐시에 있는지 확인.
이쪽이 `qwer deploy2` 의 실제 동작과 일치한다.

```bash
HOST=${1:-seedbox}
PKG=${2:-xpra}
OUT=$(nix --extra-experimental-features 'nix-command flakes' eval --impure --raw \
  ".#nixosConfigurations.${HOST}.pkgs.${PKG}.outPath")
HASH=$(basename "$OUT" | cut -d- -f1)
CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://cache.nixos.org/${HASH}.narinfo")
echo "$OUT"
echo "cache.nixos.org/${HASH}.narinfo -> $CODE  ($([ "$CODE" = 200 ] && echo HIT || echo MISS))"
```

## check-cache-rev

임의의 nixpkgs revision에서 패키지가 캐시에 있는지 확인. (채널 revision 비교용)

```bash
REV=$1
PKG=${2:-xpra}
SYS=${3:-x86_64-linux}
OUT=$(nix --extra-experimental-features 'nix-command flakes' eval --impure --raw \
  "github:nixos/nixpkgs/${REV}#legacyPackages.${SYS}.${PKG}.outPath")
HASH=$(basename "$OUT" | cut -d- -f1)
CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://cache.nixos.org/${HASH}.narinfo")
echo "$OUT"
echo "cache.nixos.org/${HASH}.narinfo -> $CODE  ($([ "$CODE" = 200 ] && echo HIT || echo MISS))"
```

## current-channel-rev

현재 채널로 승격된 nixpkgs revision 조회. (lock이 최신 채널인지 비교)

```bash
release=${1:-nixos-25.11}
curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" \
  | jq -r ".data.result[] | select(.metric.channel==\"$release\") | .metric.revision"
```

## locked-rev

현재 flake.lock의 nixpkgs revision 확인.

```bash
nix --extra-experimental-features 'nix-command flakes' flake metadata --json \
  | jq -r '.locks.nodes.nixpkgs.locked.rev'
```

## why-rebuilt

캐시 미스인 패키지가 plain nixpkgs 대비 **무엇이 다른지** nix-diff로 추적.
캐시 미스 원인을 끝까지 규명하는 핵심 도구. plain은 호스트와 동일 system으로 평가됨.

```bash
HOST=${1:-seedbox}
PKG=${2:-xpra}
SYS=$(nix --extra-experimental-features 'nix-command flakes' eval --raw --impure \
  ".#nixosConfigurations.${HOST}.pkgs.stdenv.hostPlatform.system")
PLAIN=$(nix eval --raw --impure --expr \
  "(builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${SYS}.${PKG}.drvPath")
HOSTDRV=$(nix --extra-experimental-features 'nix-command flakes' eval --impure --raw \
  ".#nixosConfigurations.${HOST}.pkgs.${PKG}.drvPath")
echo "system: $SYS"
echo "plain : $PLAIN"
echo "host  : $HOSTDRV"
nix run --extra-experimental-features 'nix-command flakes' nixpkgs#nix-diff -- "$PLAIN" "$HOSTDRV" \
  | grep -E "named \`|do not match" | head -20
```

## 해결 방향

현재 케이스(ffmpeg useunstable → opencv/xpra 재빌드):

- **근본 해결**: `overlay.nix:136-137` 의 `useunstable "ffmpeg" / "ffmpeg-full"` 를 제거하면
  xpra/opencv 가 순정 nixpkgs(ffmpeg-8.0)로 평가되어 cache.nixos.org HIT.
  단 ffmpeg 신버전이 필요한 다른 패키지가 있으면 trade-off.
- **차선책**: 자체 바이너리 캐시(harmonia `seedbox-impx:5000`)에 한 번 빌드한 결과를
  push 해두고 다른 호스트가 substituter로 재사용. overlay는 유지하되 재빌드는 1회로 한정.
- 깊은 의존성(ffmpeg/openssl/python/stdenv 류)을 `useunstable` 로 바꾸면
  그걸 쓰는 클로저 전체가 캐시 미스가 된다는 점을 인지하고 추가할 것.

일반 원칙:

- 캐시 미스 디버깅 순서: `locked-rev` ↔ `current-channel-rev` 비교 → `check-cache`(plain, 동일 system) →
  `check-cache-host`(overlay 적용) → 둘이 갈리면 `why-rebuilt` 로 차이 입력 추적.
- 비교는 항상 **동일 system** 끼리 (seedbox=aarch64-linux). 플랫폼 혼동이 오진의 주원인.
- 항상 `nix flake update` 단독 실행 금지 → `qwer.md` 의 `update` 레시피 사용 (채널 revision override 포함).
