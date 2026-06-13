#!/usr/bin/env bash
# supercharger-opencode installer
# Curl-piped single-file installer for opencode skills.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add claude-design
#   curl -fsSL .../install.sh | bash -s -- list
#   curl -fsSL .../install.sh | bash -s -- info p5js
#   curl -fsSL .../install.sh | bash -s -- remove claude-design
#
# Or after git clone:
#   ./install.sh add design
#   ./install.sh list
#
# Env:
#   SUPERCHARGER_INSTALL_DIR   override default install path (default: ~/.config/opencode/skill)
#   SUPERCHARGER_BRANCH        override default branch (default: main)

set -euo pipefail

REPO="srivtx/supercharger-opencode"
BRANCH="${SUPERCHARGER_BRANCH:-main}"
RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
ARCHIVE_URL="https://codeload.github.com/$REPO/tar.gz/$BRANCH"
INSTALL_DIR="${SUPERCHARGER_INSTALL_DIR:-$HOME/.config/opencode/skill}"

die()   { printf 'error: %s\n' "$*" >&2; exit 1; }
info()  { printf '\033[36m%s\033[0m\n' "$*"; }
ok()    { printf '\033[32m%s\033[0m\n' "$*"; }
warn()  { printf '\033[33m%s\033[0m\n' "$*"; }

have()  { command -v "$1" >/dev/null 2>&1; }

for cmd in curl tar; do
  have "$cmd" || die "missing required tool: $cmd"
done

fetch_manifest() {
  local dest
  dest=$(mktemp)
  curl -fsSL "$RAW_URL/manifest.json" -o "$dest" || die "could not fetch manifest from $RAW_URL/manifest.json"
  echo "$dest"
}

fetch_skill_to() {
  # fetch_skill_to <category> <skill> <dest>
  local category="$1" skill="$2" dest="$3"
  local tmp
  tmp=$(mktemp -d)
  # tarball root is supercharger-opencode-<branch>/, so strip 2 components to get <category>/<skill>
  curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$tmp" "supercharger-opencode-$BRANCH/$category/$skill" 2>/dev/null \
    || die "skill not found in repo: $category/$skill"
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -R "$tmp/supercharger-opencode-$BRANCH/$category/$skill" "$dest"
  rm -rf "$tmp"
}

fetch_category_to() {
  # fetch_category_to <category> <dest>
  local category="$1" dest="$2"
  local tmp
  tmp=$(mktemp -d)
  curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$tmp" "supercharger-opencode-$BRANCH/$category" 2>/dev/null \
    || die "category not found: $category"
  rm -rf "$dest/$category"
  mkdir -p "$dest"
  cp -R "$tmp/supercharger-opencode-$BRANCH/$category" "$dest/"
  rm -rf "$tmp"
}

# ── commands ────────────────────────────────────────────────────────────────

cmd_add() {
  [ $# -ge 1 ] || die "usage: add <skill-or-category> [more ...]"
  have jq || die "missing required tool: jq (install: brew install jq / apt install jq)"

  local manifest
  manifest=$(fetch_manifest)

  mkdir -p "$INSTALL_DIR"
  info "installing to: $INSTALL_DIR"
  echo

  for target in "$@"; do
    # category?
    if jq -e --arg c "$target" '.categories[$c]' "$manifest" >/dev/null 2>&1; then
      local skills
      skills=$(jq -r --arg c "$target" '.categories[$c].skills[]' "$manifest")
      for s in $skills; do
        if [ -d "$INSTALL_DIR/$s" ]; then
          warn "skip: $s (already installed; remove first to reinstall)"
          continue
        fi
        info "+ $target/$s"
        fetch_skill_to "$target" "$s" "$INSTALL_DIR/$s"
      done
      continue
    fi

    # skill?
    if jq -e --arg s "$target" '.skills[$s]' "$manifest" >/dev/null 2>&1; then
      local cat
      cat=$(jq -r --arg s "$target" '.skills[$s].category' "$manifest")
      if [ -d "$INSTALL_DIR/$target" ]; then
        warn "skip: $target (already installed; remove first to reinstall)"
        continue
      fi
      info "+ $cat/$target"
      fetch_skill_to "$cat" "$target" "$INSTALL_DIR/$target"
      continue
    fi

    die "unknown skill or category: $target (run 'list' to see what's available)"
  done

  rm -f "$manifest"
  echo
  ok "done. restart opencode to load."
}

cmd_remove() {
  [ $# -ge 1 ] || die "usage: remove <skill> [more ...]"
  for target in "$@"; do
    if [ ! -d "$INSTALL_DIR/$target" ]; then
      warn "skip: $target (not installed)"
      continue
    fi
    info "- removing $target"
    rm -rf "$INSTALL_DIR/$target"
  done
  echo
  ok "done. restart opencode to unload."
}

cmd_list() {
  have jq || die "missing required tool: jq (install: brew install jq / apt install jq)"
  local manifest
  manifest=$(fetch_manifest)
  local cats
  cats=$(jq -r '.categories | keys[]' "$manifest")
  for cat in $cats; do
    local label
    label=$(jq -r --arg c "$cat" '.categories[$c].label' "$manifest")
    echo
    info "$cat  —  $label"
    jq -r --arg c "$cat" '.categories[$c].skills[]' "$manifest" | while read -r s; do
      local desc deps installed
      desc=$(jq -r --arg s "$s" '.skills[$s].description' "$manifest")
      deps=$(jq -r --arg s "$s" '.skills[$s].external_deps | join(", ")' "$manifest")
      if [ -d "$INSTALL_DIR/$s" ]; then installed=" [installed]"; else installed=""; fi
      printf '  %-28s %s%s\n' "$s" "$desc" "$installed"
      [ -n "$deps" ] && [ "$deps" != "" ] && printf '    deps: %s\n' "$deps"
    done
  done
  rm -f "$manifest"
  echo
}

cmd_list_categories() {
  have jq || die "missing required tool: jq (install: brew install jq / apt install jq)"
  local manifest
  manifest=$(fetch_manifest)
  jq -r '.categories | to_entries[] | "\(.key)\t\(.value.label)\t\(.value.skills | length) skills"' "$manifest" \
    | while IFS=$'\t' read -r key label count; do
        printf '  %-20s %s  (%s)\n' "$key" "$label" "$count"
      done
  rm -f "$manifest"
}

cmd_info() {
  [ $# -ge 1 ] || die "usage: info <skill>"
  have jq || die "missing required tool: jq (install: brew install jq / apt install jq)"
  local manifest skill="$1"
  manifest=$(fetch_manifest)
  if ! jq -e --arg s "$skill" '.skills[$s]' "$manifest" >/dev/null 2>&1; then
    rm -f "$manifest"
    die "unknown skill: $skill"
  fi
  local cat desc deps
  cat=$(jq -r --arg s "$skill" '.skills[$s].category' "$manifest")
  desc=$(jq -r --arg s "$skill" '.skills[$s].description' "$manifest")
  deps=$(jq -r --arg s "$skill" '.skills[$s].external_deps | join(", ")' "$manifest")
  echo
  info "$skill"
  echo "  category:     $cat"
  echo "  description:  $desc"
  if [ -n "$deps" ]; then
    echo "  dependencies: $deps"
  else
    echo "  dependencies: (none)"
  fi
  if [ -d "$INSTALL_DIR/$skill" ]; then
    echo "  status:       installed at $INSTALL_DIR/$skill"
  else
    echo "  status:       not installed"
    echo "  install:      curl ... | bash -s -- add $skill"
  fi
  echo
  rm -f "$manifest"
}

cmd_help() {
  cat <<EOF
supercharger-opencode installer

USAGE
  $0 <command> [args]

COMMANDS
  add <skill|category> [...]   install one or more skills or whole categories
  remove <skill> [...]         uninstall one or more skills
  list                         show all available skills and their install status
  list-categories              show category summary
  info <skill>                 show details for one skill
  help                         show this message

EXAMPLES
  $0 add claude-design                 # install one skill
  $0 add design                        # install all 5 design skills
  $0 add claude-design p5js humanizer  # install several at once
  $0 info p5js                         # what does p5js do?
  $0 remove claude-design              # uninstall
  $0 list                              # see everything

CURL ONE-LINER
  curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/install.sh | bash -s -- add claude-design

ENV
  SUPERCHARGER_INSTALL_DIR   install path (default: $INSTALL_DIR)
  SUPERCHARGER_BRANCH        git branch (default: $BRANCH)

After installing, restart opencode to load the skills.
EOF
}

# ── entry point ─────────────────────────────────────────────────────────────

case "${1:-help}" in
  add)              shift; cmd_add "$@" ;;
  remove|rm|uninstall) shift; cmd_remove "$@" ;;
  list|ls)          cmd_list ;;
  list-categories|ls-categories|categories|cats) cmd_list_categories ;;
  info|show)        shift; cmd_info "$@" ;;
  help|--help|-h|"") cmd_help ;;
  *)                die "unknown command: $1 (try 'help')" ;;
esac
