# Nix 바이너리 캐시 존재 여부 확인

빌드 전에 특정 패키지/커널이 바이너리 캐시에 있는지 확인하면, 1코어 서버 같은 저사양 머신에서 긴 로컬 빌드나 OOM을 피할 수 있습니다.

## 1. Store path 얻기

평가하려는 대상의 out path를 얻습니다:

```bash
# 특정 호스트의 커널
nix eval --impure --raw ".#nixosConfigurations.<hostname>.pkgs.cachyosKernels.linuxPackages-cachyos-server.kernel"

# 임의의 패키지
nix eval --impure --raw ".#nixosConfigurations.<hostname>.pkgs.<pkgname>"

# 호스트 전체 toplevel (루트 derivation)
nix eval --impure --raw ".#nixosConfigurations.<hostname>.config.system.build.toplevel"

# Mac (darwin) 호스트 — 오버레이가 적용된 실제 derivation
nix eval --impure --raw ".#darwinConfigurations.txxx.pkgs.<pkgname>"

# Mac 호스트 전체 toplevel
nix eval --impure --raw ".#darwinConfigurations.txxx.config.system.build.toplevel"

# 오버레이를 거치지 않은 raw nixpkgs / nixpkgs-unstable 패키지 (Hydra 빌드 여부 진단용)
nix eval --impure --raw --expr \
  '(builtins.getFlake (toString ./.)).inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin.<pkgname>.outPath'
```

출력 예시:
```
/nix/store/5kv8svwzlcflqhm1c68gjgdyk209byqh-linux-cachyos-server-7.0.0
```

경로 앞부분의 32자리 해시(`5kv8svwzlcflqhm1c68gjgdyk209byqh`)가 캐시 조회 키입니다.

## 2. 캐시에서 narinfo 조회

`<cache-url>/<hash>.narinfo`가 존재하면 캐시에 있습니다.

```bash
HASH=5kv8svwzlcflqhm1c68gjgdyk209byqh

# NixOS 공식 캐시
curl -sI https://cache.nixos.org/${HASH}.narinfo | head -1

# 프로젝트에서 쓰는 추가 캐시 (예: cachyos용 attic)
curl -sI https://attic.xuyh0120.win/lantian/${HASH}.narinfo | head -1
```

- `HTTP/2 200` → 캐시에 존재, `substitute` 가능
- `HTTP/2 404` → 캐시에 없음, 로컬 빌드 필요

narinfo 내용(크기, 의존성 등)도 보고 싶으면 `-I` 대신 본문을 받습니다:

```bash
curl -s https://cache.nixos.org/${HASH}.narinfo
```

## 3. 여러 substituter 일괄 확인

```bash
HASH=5kv8svwzlcflqhm1c68gjgdyk209byqh
for url in \
  https://cache.nixos.org \
  https://attic.xuyh0120.win/lantian \
  ; do
  code=$(curl -sI -o /dev/null -w "%{http_code}" "${url}/${HASH}.narinfo")
  echo "${code}  ${url}"
done
```

## 4. `nix path-info`로 확인 (대안)

설정된 substituter를 모두 자동 사용:

```bash
nix path-info --store https://cache.nixos.org /nix/store/5kv8svwzlcflqhm1c68gjgdyk209byqh-linux-cachyos-server-7.0.0
```

- 경로를 출력하면 존재, 에러면 없음.

## 5. 전체 시스템이 캐시만으로 완성되는지 확인

모든 의존성까지 포함해 빌드할 게 있는지 dry-run:

```bash
nix build --dry-run ".#nixosConfigurations.<hostname>.config.system.build.toplevel"
```

출력에서:
- `will be fetched` → 캐시에서 가져옴 (문제 없음)
- `will be built` → 로컬 빌드 필요 (저사양 서버에서 주의)

Mac (txxx)에서 같은 dry-run:

```bash
nix build --dry-run ".#darwinConfigurations.txxx.config.system.build.toplevel"
```

## 6. cache.nixos.org는 unfree 패키지를 캐싱하지 않음

자주 놓치는 사실: **cache.nixos.org는 라이선스가 unfree인 패키지를 빌드/캐싱하지 않습니다.** 정책상 무료(free) 라이선스 derivation만 빌드합니다. 따라서 다음은 commit과 무관하게 항상 로컬 빌드입니다:

- `google-chrome`, `firefox-bin`
- `vscode`, `jetbrains.*`
- `omnissa-horizon-client`, `claude-code-bin`
- 기타 `meta.license`가 unfree인 모든 패키지

(주의: 이름이 비슷해도 `ffmpeg-full`은 nixpkgs에서 기본적으로 free 라이선스로 평가됩니다 — 이 경우는 §아래 결정 트리의 4번 케이스에 해당합니다.)

확인:

```bash
# 패키지의 license 확인
nix eval --raw --impure --expr \
  '(builtins.getFlake (toString ./.)).inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin.ffmpeg-full.meta.license.shortName or "free"'
# unfree → 캐시 미스 확정
```

대안:
- Free 변종으로 교체 (예: `ffmpeg-full` → `ffmpeg` 또는 `ffmpeg_7`)
- Unfree도 캐싱하는 별도 substituter 추가 (자체 attic, 커뮤니티 캐시 등)
- 로컬 빌드 수용

또한 `txxx.configuration.nix`의 `google-chrome.override { commandLineArgs = ... }`처럼 `override`/`overrideAttrs`로 인자를 바꾸면 derivation 해시가 바뀌어 — 설령 원본이 캐싱 대상이라도 — 항상 미스가 됩니다.

## 7. `nixpkgs-unstable` / `nixpkgs-nightly`가 master 핀일 때

이 저장소의 `flake.nix`는 두 input을 **`master` 브랜치**에 직접 핀하고 있습니다:

```nix
nixpkgs-unstable.url = "github:NixOS/nixpkgs/master?shallow=1";
nixpkgs-nightly.url  = "github:NixOS/nixpkgs/master?shallow=1";
```

cache.nixos.org는 **Hydra가 빌드해서 채널 브랜치로 푸시한 commit만** 캐싱합니다 (그리고 §6대로 그 중 free 패키지만). `master`의 임의 commit이 채널 commit과 일치하지 않으면 free 패키지조차 캐시 미스합니다.

### 진단: 잠긴 commit이 채널 commit인지 확인 (Mac 기준)

`hello`(거의 항상 Hydra에서 빌드되는 가벼운 패키지)의 캐시 여부로 commit 자체가 채널 commit인지 판단합니다:

```bash
OUT=$(nix eval --impure --raw --expr \
  '(builtins.getFlake (toString ./.)).inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin.hello.outPath')
HASH=$(basename "$OUT" | cut -d- -f1)
curl -sI -o /dev/null -w "%{http_code}\n" "https://cache.nixos.org/${HASH}.narinfo"
```

- `200` → 채널 commit, 다른 패키지가 미스면 그 패키지가 darwin job set에 없거나 broken
- `404` → 채널 commit 아님, 이 input을 통한 거의 모든 패키지가 미스

현재 잠긴 commit 확인:

```bash
jq -r '.nodes["nixpkgs-unstable"].locked | "rev=\(.rev)\nlastModified=\(.lastModified|todate)"' flake.lock
```

### 해결: 채널 브랜치로 핀 변경

darwin 사용자는 packages-only 채널인 `nixpkgs-unstable`이 일반적입니다 (`nixos-unstable`은 NixOS 모듈 평가 기준이라 darwin 패키지 일부가 빌드되지 않습니다):

```nix
# flake.nix
nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
```

변경 후 `nix flake update nixpkgs-unstable` 한 다음 위 진단 명령으로 `200`이 나오는지 재확인합니다.

### 결정 트리 (cache.nixos.org 기준)

특정 패키지가 미스일 때 원인을 좁히는 순서:

1. `meta.license`가 unfree? → §6, 영구 미스. 다른 substituter나 free 변종으로.
2. `override`/`overrideAttrs`로 인자를 바꿨는가? → 해시 변경, 영구 미스.
3. `hello`도 미스인가? → 잠긴 commit이 채널 commit이 아닐 가능성. 본 섹션의 핀 변경 검토.
4. `hello`는 200인데 해당 패키지만 미스? → Hydra의 aarch64-darwin job set에 그 패키지가 빠졌거나 broken. nixpkgs `meta.platforms` / Hydra 상태 확인.

