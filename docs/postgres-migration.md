# Postgres 마이그레이션: oci-aca-001 → oci-xnzm-a1

`oci-aca-001`(PG 16)의 데이터를 새로 구성한 `oci-xnzm-a1`(PG 18 컨테이너)로 옮기는 절차.

## 결론

**가능하다.** 단, 이번 작업의 **대상은 `postgres` 데이터베이스 하나**다.
(`dbos_starter_go`, `matrix-synapse`는 제외 — 사용자 요청)

논리 덤프/복원(`pg_dump -Fc` → `pg_restore`)으로 진행한다. 스키마·확장·소유권·콜레이션을
target의 임시 DB에 실제로 복원해 검증을 마쳤다(테이블 31개, `pg_rational` 포함, 에러 0건).

## 현황 (점검 결과)

| 항목 | source `oci-aca-001` | target `oci-xnzm-a1` |
|---|---|---|
| 버전 | PostgreSQL **16.14** (aarch64) | PostgreSQL **18.4** (aarch64) |
| 구동 | NixOS `services.postgresql` (호스트) | podman 컨테이너 `ghcr.io/aca/containers/postgres-18` |
| 인증 | `trust` (local / 100.0.0.0/8 / 192.168.195.0/24) | port `5432` 노출 |
| 로케일 | `en_US.UTF-8` 사용 가능 | **`C`만 사용 가능** (`en_US.UTF-8` 없음) |
| `postgres` DB | UTF8 / `en_US.UTF-8` / **499 MB / 31 테이블** | UTF8 / **`C`** (기본 빈 DB) |

대상 `postgres` DB의 주요 테이블:

| 테이블 | 크기 | 비고 |
|---|---|---|
| `public.tsdata` | 451 MB | 약 310만 행, **일반 테이블**(timescaledb 하이퍼테이블 아님) |
| `public.tb_one_usdc_trades` | 23 MB | |
| `public.ts_completed_kr_new` 외 | < 10 MB | |

확장: `pg_rational 0.0.2`, `plpgsql` — **둘 다 target에 설치 가능**(검증됨).
`timescaledb`는 source에 preload만 되어 있고 **실제 하이퍼테이블은 없음** → 무시해도 됨.

## 주의사항

1. **콜레이션 변경 (`en_US.UTF-8` → `C`)**
   target 컨테이너에는 `C` 로케일만 있어, source의 `postgres` DB를 그대로 재생성할 수 없다.
   따라서 **target의 기존 `C` 콜레이션 `postgres` DB 안으로 객체를 복원**한다.
   - 검증 결과 `rational` 타입 컬럼 0개, `en_US`를 명시한 컬럼 콜레이션 0개 → 데이터 손실 없음.
   - 영향은 **텍스트 정렬/비교 순서**뿐이며, 본 데이터는 대부분 숫자·타임스탬프라 사실상 무해
     (오히려 `C`가 더 빠름). 만약 `en_US.UTF-8` 정렬이 꼭 필요하면 컨테이너 이미지에
     로케일을 추가해 재빌드해야 한다.

2. **버전 16 → 18 (크로스 메이저)**
   상위 버전(18)의 `pg_dump`/`pg_restore`로 하위 서버(16)를 덤프/복원하는 것이 정석이다.
   target 컨테이너 안의 v18 바이너리를 쓰면 가장 안전하다.
   (워크스테이션의 v17 클라이언트로도 검증은 통과했다.)

3. **다운타임 / 일관성**
   source `postgres` DB에 실시간 연결 약 76개가 붙어 있다(쓰기 가능성). `pg_dump`는 시작
   시점 스냅샷으로 일관성은 보장하지만, **덤프 시작 이후의 쓰기는 유실**된다.
   데이터 누락 없이 전환하려면 **덤프 전에 쓰기 애플리케이션을 멈춰야 한다.**

4. **소유권/권한**
   객체 소유자는 모두 `postgres`. `--no-owner --no-acl`로 복원해 `rok` 등 role 마이그레이션을
   생략한다.

## 절차

### 0. 사전 점검 (source가 살아있는지)

```bash
psql "postgres://postgres:postgres@oci-aca-001:5432/postgres" -tAc "select version();"
```

### 1. 쓰기 애플리케이션 중단 (다운타임 시작)

source 호스트(`oci-aca-001`)에서 `postgres` DB에 쓰는 서비스를 멈춘다.
연결 수가 줄었는지 확인:

```bash
psql "postgres://postgres:postgres@oci-aca-001:5432/postgres" \
  -tAc "select count(*) from pg_stat_activity where datname='postgres' and usename<>'postgres';"
```

### 2. 덤프 + 복원

아래는 **target 호스트(`oci-xnzm-a1`)에 ssh 접속**해, 컨테이너의 v18 도구로 실행하는 버전이다.
볼륨 매핑상 호스트 `/var/lib/postgresql/oci-xnzm-a1` = 컨테이너 `/var/lib/postgresql/data`.

```bash
C=oci-xnzm-a1          # podman 컨테이너 이름(=호스트명)
SRC=oci-aca-001

# (a) source의 postgres DB를 커스텀 포맷으로 덤프 (소유권/권한 제외)
podman exec -e PGPASSWORD=postgres "$C" \
  pg_dump -h "$SRC" -U postgres -Fc --no-owner --no-acl \
          -f /var/lib/postgresql/data/postgres.dump postgres

# (b) target의 기존 postgres DB로 복원 (C 콜레이션 DB 안으로)
podman exec "$C" \
  pg_restore -U postgres -d postgres --no-owner --no-acl --exit-on-error \
             /var/lib/postgresql/data/postgres.dump
```

> 컨테이너 접근 없이 워크스테이션에서 한 번에 파이프로 처리해도 된다(검증된 방식):
> ```bash
> pg_dump "postgres://postgres:postgres@oci-aca-001:5432/postgres" \
>   -Fc --no-owner --no-acl \
> | pg_restore -d "postgres://postgres:postgres@oci-xnzm-a1:5432/postgres" \
>     --no-owner --no-acl --exit-on-error
> ```
> 단 이 경우 클라이언트가 v18 이상이면 더 안전하다.

복원을 **다시 시도**해야 할 때(이미 일부 객체가 들어간 경우)는 `--clean --if-exists`를 추가:

```bash
podman exec "$C" pg_restore -U postgres -d postgres \
  --no-owner --no-acl --clean --if-exists /var/lib/postgresql/data/postgres.dump
```

### 3. 검증

```bash
# 테이블 수 (source와 동일해야 함: 31)
psql "postgres://postgres:postgres@oci-xnzm-a1:5432/postgres" \
  -tAc "select count(*) from pg_tables where schemaname='public';"

# 확장 (pg_rational, plpgsql)
psql "postgres://postgres:postgres@oci-xnzm-a1:5432/postgres" \
  -tAc "select extname from pg_extension order by 1;"

# 행 수 대조 (가장 큰 테이블)
for h in oci-aca-001 oci-xnzm-a1; do
  echo -n "$h tsdata: "
  psql "postgres://postgres:postgres@$h:5432/postgres" -tAc "select count(*) from public.tsdata;"
done
```

### 4. 컷오버 (DSN 전환)

애플리케이션 접속 대상을 새 서버로 돌린다. 리포의 `env.nix:45`:

```nix
# 변경 전
"PGKV_DSN" = "postgres://postgres:postgres@oci-aca-001:5432/postgres";
# 변경 후
"PGKV_DSN" = "postgres://postgres:postgres@oci-xnzm-a1:5432/postgres";
```

수정 후 `./@/switch`로 반영하고, 1단계에서 멈춘 서비스를 새 DSN으로 재기동한다.

## 롤백

전환 후 문제가 생기면, source(`oci-aca-001`)는 그대로 살아있으므로
`env.nix`의 DSN을 원래대로 되돌리고 `./@/switch` 하면 즉시 복귀된다.
(따라서 마이그레이션이 검증될 때까지 source DB는 삭제하지 말 것.)
