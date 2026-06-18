# archive-0 부트 디스크 교체

archive-0 서버의 부트(루트) 디스크를 새 디스크로 교체하는 절차입니다.

새 디스크를 **다른 NixOS 머신**(예: 작업용 PC)에 연결해서 `nixos-install`로
archive-0 시스템을 설치한 뒤, 디스크를 archive-0에 물리적으로 옮겨 끼웁니다.

## 핵심 아이디어

`hardware/archive-0.nix`는 루트/부트 파일시스템을 **UUID로 하드코딩**하고 있습니다.

```nix
fileSystems."/".device      = "/dev/disk/by-uuid/d6ac3c2f-a884-4088-bdf6-93804aed5eb4"; # ext4
fileSystems."/boot".device  = "/dev/disk/by-uuid/4144-62D2";                            # vfat(ESP)
```

따라서 새 디스크의 파티션을 **기존과 동일한 UUID로 포맷**하면 설정 파일을
전혀 수정할 필요 없이 디스크만 갈아끼우면 바로 부팅됩니다.

데이터 디스크(parity / data01–10)는 별도 디스크이며 `nofail` 옵션이라
이번 교체와 무관합니다. 부트 디스크만 새로 만들면 됩니다.

## 전제 조건

- 작업 머신이 **x86_64 NixOS**여야 합니다 (archive-0 클로저를 네이티브 빌드).
- 새 디스크가 작업 머신에 연결되어 있고 디바이스 경로를 알아야 합니다.
  - 아래 예시는 `/dev/sda` 기준입니다. **반드시 본인 환경에서 재확인하세요.**
- archive-0는 **UEFI + systemd-boot**로 부팅합니다 (GPT + ESP 필요).

## 0. 대상 디스크 확인 (중요)

> ⚠️ 이 절차는 대상 디스크를 **완전히 초기화**합니다.
> 디바이스 경로를 잘못 지정하면 엉뚱한 디스크가 지워집니다.

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL,UUID
```

지울 디스크가 맞는지(용량/라벨 등) 확인하고, 기존 데이터는 백업합니다.
아래에서는 대상 디스크를 `DISK` 변수로 둡니다.

```bash
DISK=/dev/sda   # ← 본인 환경에 맞게 수정
```

## 1. 파티션 (GPT: ESP 1G + 루트 나머지)

```bash
sudo wipefs -a "$DISK"
sudo sgdisk -Z "$DISK"
sudo sgdisk -n1:0:+1G -t1:ef00 -c1:boot "$DISK"   # EFI System Partition
sudo sgdisk -n2:0:0   -t2:8300 -c2:root "$DISK"   # 루트
sudo partprobe "$DISK"
```

> 파티션 디바이스 경로는 디스크 종류에 따라 다릅니다.
> - SATA/USB: `${DISK}1`, `${DISK}2`  (예: `/dev/sda1`)
> - NVMe:     `${DISK}p1`, `${DISK}p2` (예: `/dev/nvme0n1p1`)

## 2. 기존과 동일한 UUID로 포맷 (← 설정 수정 불필요의 핵심)

```bash
# ESP: FAT volume id 4144-62D2  →  -i 414462D2 (대시 없는 hex)
sudo mkfs.fat -F32 -i 414462D2 "${DISK}1"

# 루트 ext4: 기존 UUID 그대로 지정
sudo mkfs.ext4 -U d6ac3c2f-a884-4088-bdf6-93804aed5eb4 "${DISK}2"
```

확인:

```bash
sudo blkid "${DISK}1" "${DISK}2"
# ${DISK}1: UUID="4144-62D2" TYPE="vfat"
# ${DISK}2: UUID="d6ac3c2f-a884-4088-bdf6-93804aed5eb4" TYPE="ext4"
```

## 3. 마운트

```bash
sudo mount "${DISK}2" /mnt
sudo mkdir -p /mnt/boot
sudo mount "${DISK}1" /mnt/boot
```

## 4. flake로 설치

```bash
sudo nixos-install \
  --flake /home/rok/src/git.internal/nix-config#archive-0 \
  --no-root-passwd
```

- archive-0 클로저를 빌드 후 `/mnt`에 설치하고 부트로더(systemd-boot)를
  ESP에 기록합니다.
- 루트 비밀번호를 따로 설정하려면 `--no-root-passwd`를 빼고 실행합니다.
  (일반 사용자 계정/비번은 config에 정의돼 있습니다.)

## 5. 정리 후 물리 교체

```bash
sudo umount -R /mnt
```

작업 머신 종료 → 새 디스크를 archive-0에 장착 → 기존 부트 디스크 제거(또는
부팅 순서에서 새 디스크를 우선으로 설정) → 부팅.

## 알아둘 점

- **EFI 변수 부작용**: archive-0 config는 `boot.loader.efi.canTouchEfiVariables = true`라,
  설치 중 `bootctl`이 **작업 머신의** NVRAM에 부팅 엔트리를 추가할 수 있습니다.
  죽은 엔트리라 무해하고, archive-0는 ESP의 fallback 경로
  (`EFI/BOOT/BOOTX64.EFI`)로 부팅되므로 동작에는 문제없습니다.
  거슬리면 작업 머신에서 `efibootmgr`로 확인 후 `sudo efibootmgr -b <num> -B`로 제거합니다.
- **데이터 디스크**(parity/data01–10)는 설치 시점에 없어도 무방하며,
  archive-0에서 UUID로 자동 마운트됩니다.
- **커널 모듈**: 새 디스크가 archive-0에서 SATA로 잡히면(`sd_mod`/`ahci`)
  `boot.initrd.availableKernelModules`에 이미 포함돼 있어 부팅됩니다.
  다른 인터페이스(NVMe 등)면 모듈 포함 여부를 확인하세요.

## 대안: UUID를 맞추지 않는 경우

새 파티션을 임의 UUID로 포맷했다면, 설치 후 `hardware/archive-0.nix`의
`/` 및 `/boot` device UUID를 새 값으로 바꾸고 archive-0에서
`./@/switch`(또는 `nixos-rebuild switch`)로 반영해야 합니다.
UUID를 맞추는 방식이 설정 변경이 없어 더 간단하므로 권장합니다.
