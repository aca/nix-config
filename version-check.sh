REV=342ad3e86541a537a088b4f4b56c866304e73a4f
OUT=$(nix eval --raw "github:NixOS/nixpkgs/${REV}#svt-av1")
echo "$OUT"                       # /nix/store/<hash>-svt-av1-3.1.2
HASH=$(basename "$OUT" | cut -d- -f1)
curl -s -o /dev/null -w "%{http_code}\n" "https://cache.nixos.org/${HASH}.narinfo"



