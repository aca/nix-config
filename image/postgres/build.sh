#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

nix build .#packages.x86_64-linux.dockerImage -o result

docker import \
  --change 'ENTRYPOINT ["/init"]' \
  --change 'STOPSIGNAL SIGRTMIN+3' \
  --change 'EXPOSE 5432' \
  result/tarball/nixos-system-*.tar.xz \
  postgres-nix:latest

echo
echo "run with:"
echo "  docker run --privileged -p 5432:5432 postgres-nix:latest"
echo "  # logs: docker exec <name> journalctl -fu postgresql"
