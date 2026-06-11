#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: $0 <registry/image>[:tag]" >&2
  echo "example: $0 myrepo/postgres-nix:latest" >&2
  exit 1
fi

REF="$1"
REPO="${REF%:*}"
TAG="${REF#*:}"
[ "$REPO" = "$TAG" ] && TAG="latest"

cd "$(dirname "$0")"

declare -A ARCH=( [x86_64-linux]=amd64 [aarch64-linux]=arm64 )

for sys in "${!ARCH[@]}"; do
  a="${ARCH[$sys]}"
  echo ">>> building $sys"
  nix build ".#packages.${sys}.dockerImage" -o "result-${a}"

  echo ">>> loading + pushing ${REPO}:${TAG}-${a}"
  docker load < "result-${a}"
  docker tag "postgres-nix:latest-${sys}" "${REPO}:${TAG}-${a}"
  docker push "${REPO}:${TAG}-${a}"
done

echo ">>> creating multi-arch manifest ${REPO}:${TAG}"
docker buildx imagetools create -t "${REPO}:${TAG}" \
  "${REPO}:${TAG}-amd64" \
  "${REPO}:${TAG}-arm64"

echo ">>> done: ${REPO}:${TAG}"
