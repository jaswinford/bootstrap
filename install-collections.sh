#!/usr/bin/env bash
set -euo pipefail

# Detect all collections referenced in role task files
COLLECTIONS=$(
  grep -rh --include='*.yml' -oE '[a-z]+\.[a-z]+\.[a-z_]+:' roles/ \
  | sed 's/\.[^.]*:$//' \
  | sort -u \
  | grep -v '^ansible\.builtin$'
)

if [[ -z "$COLLECTIONS" ]]; then
  echo "No external collections detected."
  exit 0
fi

for collection in $COLLECTIONS; do
  if ansible-galaxy collection list | grep -q "^${collection}"; then
    echo "[skip]    ${collection} — already installed"
  else
    echo "[install] ${collection}"
    ansible-galaxy collection install "${collection}"
  fi
done
