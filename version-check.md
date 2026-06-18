# 패키지 버전 / PR 포함 여부 확인 메모

## 현재 시스템 (svt-av1 / ffmpeg)

- **ffmpeg**: 8.1 (`--enable-libsvtav1`로 빌드)
- **svt-av1 (인코더)**: **3.1.2** (`libSvtAv1Enc.so.3`)
  - 실제 링크 경로: `/nix/store/3q4wwqny99xr196bg2j5s2mn0pkrg5vi-svt-av1-3.1.2/lib/libSvtAv1Enc.so.3`

확인 명령:
```bash
ffmpeg -version | head -1
ldd "$(readlink -f "$(command -v ffmpeg)")" | grep -i svt
```

## PR #483169 (svt-av1: 3.1.2 -> 4.1.0) 포함 여부

| 확인 항목 | 결과 |
|------|------|
| PR 머지 대상 | `staging` 브랜치, 머지커밋 `342ad3e8` (2026-05-29) |
| `nixos-unstable-small` (rev `ce0fb89`) svt-av1 | 3.1.2 |
| `ab5f04b8865f` 의 svt-av1 | **3.1.2** (아직 4.1.0 미포함) |

→ PR은 `staging`에 머지됐지만 아직 unstable(-small)로 흘러오지 않음.

## 확인 방법

### 1. 가장 확실 — 커밋에서 버전 직접 평가
git 토폴로지(staging/master 머지 구조)와 무관하게 실제 빌드 버전을 알려줌.
```bash
nix eval --raw "github:NixOS/nixpkgs/<rev>#svt-av1.version"
# 예) ab5f04b8865f -> 3.1.2
```

### 2. PR 머지 커밋 → 조상(포함) 검사
```bash
gh pr view 483169 --repo NixOS/nixpkgs --json mergeCommit,mergedAt,state,baseRefName,title
# mergeCommit: 342ad3e8..., baseRefName: staging

gh api repos/NixOS/nixpkgs/compare/342ad3e8...ab5f04b8865f \
  --jq '{status, ahead_by, behind_by}'
# -> diverged (staging 경유라 직접 조상 검사는 부정확)
```
**주의**: `staging` 머지 PR은 staging-next → master로 들어가면서 *다른 머지 커밋*이 됨.
이 방식은 master에 직접 머지된 PR에만 깔끔하게 적용됨. staging 경유 PR은 **방법 1**이 정답.

## 4.1.0을 쓰려면

- svt-av1 4.1.0이 staging → staging-next → master(unstable)로 흘러올 때까지
  nixpkgs를 더 최신 커밋으로 업데이트(`nix flake update`), 또는
- 급하면 `342ad3e8` 이후 커밋을 가리키는 overlay로 svt-av1만 끌어올림.

## 특정 커밋 기준 바이너리 캐시 존재 확인

원리: 커밋에서 패키지의 **store path를 평가**(빌드 없이) → 그 해시로 캐시 서버에 narinfo가 있는지 조회.

### 1. store path / 해시 얻기 (빌드 안 함)
```bash
REV=ab5f04b8865f
OUT=$(nix eval --raw "github:NixOS/nixpkgs/${REV}#svt-av1")
echo "$OUT"                       # /nix/store/<hash>-svt-av1-3.1.2
HASH=$(basename "$OUT" | cut -d- -f1)
```

### 2. narinfo HTTP 조회 (가장 빠름)
```bash
curl -s -o /dev/null -w "%{http_code}\n" "https://cache.nixos.org/${HASH}.narinfo"
# 200 = 캐시 있음, 404 = 없음(직접 빌드 필요)
```
narinfo 내용까지 보기 (NAR 크기, deriver 등):
```bash
curl -s "https://cache.nixos.org/${HASH}.narinfo"
```

### 3. nix path-info 로 확인 (한 줄)
```bash
nix path-info --store https://cache.nixos.org "$OUT"
# 출력 있으면 캐시 존재, 에러면 없음
```

### 4. 빌드 전 무엇이 받아질지 미리보기 (dry-run)
```bash
nix build --dry-run "github:NixOS/nixpkgs/${REV}#svt-av1"
# "these N paths will be fetched" = 캐시에서 다운로드
# "these N derivations will be built" = 소스 빌드 필요
```

> 참고: 다른 캐시(예: nix-community)도 같은 방식 —
> `curl .../<hash>.narinfo` 의 URL만 해당 캐시 주소로 바꾸면 됨.

## 참고: nixos-unstable-small 이란

- `nixos-unstable`과 **동일한 nixpkgs 저장소**, 채널 포인터만 다름 (패키지 집합 동일).
- 검증 패키지 수가 적어 **더 자주/빨리 갱신** → 보안 패치 빠름.
- 단, 바이너리 캐시 커버리지가 약간 낮아 일부 패키지는 소스 빌드 가능성.
- 이 저장소에선 메인 nixpkgs가 아니라 transitive input(`nixpkgs_12`)으로만 참조됨.
