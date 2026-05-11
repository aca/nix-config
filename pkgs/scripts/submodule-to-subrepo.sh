#!/usr/bin/env bash
set -euo pipefail

# assure git repo is in clean status
git diff --quiet && git diff --cached --quiet

if [ $# -lt 1 ]; then
  echo "Usage: $0 <submodule-path> [<submodule-path>...]"
  echo "Example: $0 .submodules/fff .local/share/nvim/site/pack/bundle/opt/fzf"
  exit 1
fi

for path in "$@"; do
  path="${path%/}"
  url=$(git config --file .gitmodules "submodule.${path}.url" 2>/dev/null) || {
    echo "ERROR: '$path' not found in .gitmodules"; continue
  }

  echo "=== $path ($url) ==="
  git submodule deinit -f "$path"
  git rm -f "$path"
  rm -rf ".git/modules/$path"
  git commit -m "Remove submodule $path"
  git subrepo clone "$url" "$path"
  echo ""
done
