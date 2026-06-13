#!/usr/bin/env bash
set -euo pipefail

# install.sh — copy skills into ~/.config/opencode/skill/<name>/
#
# Usage:
#   ./install.sh                 # install all
#   ./install.sh claude-design   # install specific skills
#   ./install.sh --uninstall     # remove previously installed

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)/skills"
DEST="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skill}"

if [[ "${1:-}" == "--uninstall" ]]; then
  shift
  rm -rf "$DEST"
  echo "Removed $DEST"
  exit 0
fi

mkdir -p "$DEST"

if [[ $# -eq 0 ]]; then
  targets=("$SKILLS_DIR"/*/)
else
  targets=()
  for name in "$@"; do
    if [[ -d "$SKILLS_DIR/$name" ]]; then
      targets+=("$SKILLS_DIR/$name")
    else
      echo "skip: $name (not found in skills/)" >&2
    fi
  done
fi

for src in "${targets[@]}"; do
  name="$(basename "$src")"
  dest="$DEST/$name"
  rm -rf "$dest"
  cp -R "$src" "$dest"
  echo "+ $name"
done

echo
echo "Installed to $DEST"
echo "Restart opencode to load."
