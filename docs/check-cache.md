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
