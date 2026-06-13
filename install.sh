#!/usr/bin/env bash
# supercharger-opencode installer
# Curl-piped single-file installer for opencode skills.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add claude-design
#   curl -fsSL .../install.sh | bash -s -- list
#   curl -fsSL .../install.sh | bash -s -- info p5js
#   curl -fsSL .../install.sh | bash -s -- remove --all
#
# Or after git clone:
#   ./install.sh add design
#   ./install.sh list
#
# Env:
#   SUPERCHARGER_INSTALL_DIR   override default install path (default: ~/.config/opencode/skill)
#   SUPERCHARGER_BRANCH        override default branch (default: main)

set -uo pipefail

REPO="srivtx/supercharger-opencode"
BRANCH="${SUPERCHARGER_BRANCH:-main}"
# Primary CDN: raw.githubusercontent.com (canonical GitHub).
# Fallback: jsDelivr. GitHub's raw CDN is known to cache the previous
# main-branch version for 5-30+ min after a push. If a manifest fetch
# returns a version older than the minimum we know about, we retry
# via jsDelivr before giving up.
RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
FALLBACK_URL="https://cdn.jsdelivr.net/gh/$REPO@$BRANCH"
ARCHIVE_URL="https://codeload.github.com/$REPO/tar.gz/$BRANCH"
# Bump this when the manifest gains a new top-level field. The installer
# uses it to detect a stale raw.githubusercontent.com cache and retry
# from jsDelivr.
MIN_MANIFEST_VERSION="2.1.0"
INSTALL_DIR="${SUPERCHARGER_INSTALL_DIR:-$HOME/.config/opencode/skill}"

die()   { printf 'error: %s\n' "$*" >&2; exit 1; }
info()  { printf '\033[36m%s\033[0m\n' "$*"; }
ok()    { printf '\033[32m%s\033[0m\n' "$*"; }
warn()  { printf '\033[33m%s\033[0m\n' "$*"; }

have()  { command -v "$1" >/dev/null 2>&1; }

for cmd in curl tar jq; do
  have "$cmd" || die "missing required tool: $cmd"
done

# ── fetch helpers ──────────────────────────────────────────────────────────

# Download a file with one retry on transient failure.
fetch_with_retry() {
  local url="$1" dest="$2"
  if curl -fsSL --retry 2 --retry-delay 1 "$url" -o "$dest"; then
    return 0
  fi
  # one more attempt with a longer delay for the truly stubborn
  sleep 2
  curl -fsSL --retry 1 --retry-delay 2 "$url" -o "$dest"
}

fetch_manifest() {
  local dest
  dest=$(mktemp)

  # Try primary CDN (raw.githubusercontent.com).
  if fetch_with_retry "$RAW_URL/manifest.json" "$dest"; then
    # If the raw CDN is serving a stale version (older than the minimum we
    # know about), the fetch will succeed but the install will be missing
    # features. Detect that and fall through to the fallback.
    if jq -e --arg min "$MIN_MANIFEST_VERSION" '
        .version and (.version | split(".") | map(tonumber)) as $v |
        ($min  | split(".") | map(tonumber)) as $m |
        $v[0] > $m[0] or ($v[0] == $m[0] and $v[1] > $m[1]) or
        ($v[0] == $m[0] and $v[1] == $m[1] and ($v[2] // 0) >= ($m[2] // 0))
      ' "$dest" >/dev/null 2>&1; then
      echo "$dest"
      return 0
    fi
    warn "raw.githubusercontent.com is serving a stale manifest (cache lag); falling back to jsDelivr"
  fi

  # Fallback: jsDelivr mirrors the same repo with more aggressive cache
  # invalidation.
  fetch_with_retry "$FALLBACK_URL/manifest.json" "$dest" \
    || die "could not fetch manifest from $RAW_URL/manifest.json or $FALLBACK_URL/manifest.json"
  echo "$dest"
}

# Download the full repo tarball once into a cache dir and emit its path.
fetch_tarball() {
  local cache="$1"
  local dest="$cache/repo.tar.gz"
  fetch_with_retry "$ARCHIVE_URL" "$dest" \
    || die "could not fetch tarball from $ARCHIVE_URL"
  echo "$dest"
}

# Extract a single <category>/<skill> folder from a cached tarball.
extract_skill() {
  # extract_skill <tarball> <category> <skill> <dest>
  local tarball="$1" category="$2" skill="$3" dest="$4"
  local tmp
  tmp=$(mktemp -d)
  # The tarball root is "supercharger-opencode-<branch>/", so the full path is
  # "supercharger-opencode-<branch>/<category>/<skill>".
  if ! tar -xz -C "$tmp" -f "$tarball" "supercharger-opencode-$BRANCH/$category/$skill" 2>/dev/null; then
    rm -rf "$tmp"
    return 1
  fi
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -R "$tmp/supercharger-opencode-$BRANCH/$category/$skill" "$dest"
  rm -rf "$tmp"
}

# ── commands ───────────────────────────────────────────────────────────────

cmd_add() {
  [ $# -ge 1 ] || die "usage: add <skill|category|preset> [more ...]"

  local manifest
  manifest=$(fetch_manifest)

  mkdir -p "$INSTALL_DIR"
  info "installing to: $INSTALL_DIR"
  echo

  # Download the tarball once and reuse for all targets. This makes category
  # and preset installs of N skills N times faster, and one curl hiccup no
  # longer kills the rest of the batch.
  local cache tarball
  cache=$(mktemp -d)
  tarball=$(fetch_tarball "$cache")

  local failed=0 added=0 skipped=0
  for target in "$@"; do
    # preset? (most user-friendly, check first)
    if jq -e --arg p "$target" '.presets[$p]' "$manifest" >/dev/null 2>&1; then
      local skills label
      label=$(jq -r --arg p "$target" '.presets[$p].label' "$manifest")
      skills=$(jq -r --arg p "$target" '.presets[$p].skills[]' "$manifest")
      info "preset: $target  ($label)"
      for s in $skills; do
        if [ -d "$INSTALL_DIR/$s" ]; then
          warn "skip: $s (already installed)"
          skipped=$((skipped + 1))
          continue
        fi
        local cat
        cat=$(jq -r --arg s "$s" '.skills[$s].category' "$manifest")
        info "+ $cat/$s"
        if extract_skill "$tarball" "$cat" "$s" "$INSTALL_DIR/$s"; then
          added=$((added + 1))
        else
          warn "  ! could not extract $cat/$s from tarball"
          failed=$((failed + 1))
        fi
      done
      continue
    fi

    # category?
    if jq -e --arg c "$target" '.categories[$c]' "$manifest" >/dev/null 2>&1; then
      local skills
      skills=$(jq -r --arg c "$target" '.categories[$c].skills[]' "$manifest")
      for s in $skills; do
        if [ -d "$INSTALL_DIR/$s" ]; then
          warn "skip: $s (already installed; remove first to reinstall)"
          skipped=$((skipped + 1))
          continue
        fi
        info "+ $target/$s"
        if extract_skill "$tarball" "$target" "$s" "$INSTALL_DIR/$s"; then
          added=$((added + 1))
        else
          warn "  ! could not extract $target/$s from tarball"
          failed=$((failed + 1))
        fi
      done
      continue
    fi

    # skill?
    if jq -e --arg s "$target" '.skills[$s]' "$manifest" >/dev/null 2>&1; then
      local cat
      cat=$(jq -r --arg s "$target" '.skills[$s].category' "$manifest")
      if [ -d "$INSTALL_DIR/$target" ]; then
        warn "skip: $target (already installed; remove first to reinstall)"
        skipped=$((skipped + 1))
        continue
      fi
      info "+ $cat/$target"
      if extract_skill "$tarball" "$cat" "$target" "$INSTALL_DIR/$target"; then
        added=$((added + 1))
      else
        warn "  ! could not extract $cat/$target from tarball"
        failed=$((failed + 1))
      fi
      continue
    fi

    warn "unknown target: $target (run 'list' or 'presets' to see what's available)"
    failed=$((failed + 1))
  done

  rm -rf "$cache"
  rm -f "$manifest"
  echo
  if [ "$added" -gt 0 ]; then
    ok "added $added skill(s). restart opencode to load."
  fi
  if [ "$skipped" -gt 0 ]; then
    warn "$skipped skill(s) skipped (already installed)"
  fi
  if [ "$failed" -gt 0 ]; then
    warn "$failed target(s) failed"
    exit 1
  fi
}

cmd_remove() {
  # remove [--all|-a] [<skill> ...]
  local remove_all=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --all|-a) remove_all=1; shift ;;
      *) break ;;
    esac
  done

  if [ "$remove_all" -eq 1 ]; then
    [ $# -eq 0 ] || die "--all cannot be combined with skill names"
    have jq || die "missing required tool: jq (install: brew install jq / apt install jq)"
    local manifest removed=0
    manifest=$(fetch_manifest)
    info "removing all supercharger-installed skills from $INSTALL_DIR"
    local skills
    skills=$(jq -r '.skills | keys[]' "$manifest")
    for s in $skills; do
      if [ -d "$INSTALL_DIR/$s" ]; then
        info "- removing $s"
        rm -rf "$INSTALL_DIR/$s"
        removed=$((removed + 1))
      fi
    done
    rm -f "$manifest"
    echo
    if [ "$removed" -eq 0 ]; then
      ok "nothing to remove."
    else
      ok "removed $removed skill(s). restart opencode to unload."
    fi
    return
  fi

  [ $# -ge 1 ] || die "usage: remove [--all] <skill> [more ...]"

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
  local manifest
  manifest=$(fetch_manifest)
  jq -r '.categories | to_entries[] | "\(.key)\t\(.value.label)\t\(.value.skills | length) skills"' "$manifest" \
    | while IFS=$'\t' read -r key label count; do
        printf '  %-20s %s  (%s)\n' "$key" "$label" "$count"
      done
  rm -f "$manifest"
}

cmd_info() {
  [ $# -ge 1 ] || die "usage: info <skill|preset|category>"
  local manifest target="$1"
  manifest=$(fetch_manifest)

  # preset?
  if jq -e --arg p "$target" '.presets[$p]' "$manifest" >/dev/null 2>&1; then
    local label tagline desc count
    label=$(jq -r --arg p "$target" '.presets[$p].label' "$manifest")
    tagline=$(jq -r --arg p "$target" '.presets[$p].tagline' "$manifest")
    desc=$(jq -r --arg p "$target" '.presets[$p].description' "$manifest")
    count=$(jq -r --arg p "$target" '.presets[$p].skills | length' "$manifest")
    echo
    info "$target  (preset · $count skills)"
    echo "  label:        $label"
    echo "  tagline:      $tagline"
    echo "  description:  $desc"
    echo "  install:      curl ... | bash -s -- add $target"
    echo
    rm -f "$manifest"
    return
  fi

  # category?
  if jq -e --arg c "$target" '.categories[$c]' "$manifest" >/dev/null 2>&1; then
    local label desc count
    label=$(jq -r --arg c "$target" '.categories[$c].label' "$manifest")
    desc=$(jq -r --arg c "$target" '.categories[$c].description' "$manifest")
    count=$(jq -r --arg c "$target" '.categories[$c].skills | length' "$manifest")
    echo
    info "$target  (category · $count skills)"
    echo "  label:        $label"
    echo "  description:  $desc"
    echo "  install:      curl ... | bash -s -- add $target"
    echo
    rm -f "$manifest"
    return
  fi

  # skill?
  if ! jq -e --arg s "$target" '.skills[$s]' "$manifest" >/dev/null 2>&1; then
    rm -f "$manifest"
    die "unknown target: $target (run 'list' or 'presets')"
  fi
  local cat desc deps
  cat=$(jq -r --arg s "$target" '.skills[$s].category' "$manifest")
  desc=$(jq -r --arg s "$target" '.skills[$s].description' "$manifest")
  deps=$(jq -r --arg s "$target" '.skills[$s].external_deps | join(", ")' "$manifest")
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

cmd_presets() {
  local manifest
  manifest=$(fetch_manifest)
  jq -r '.presets | to_entries[] | "\(.key)\t\(.value.label)\t\(.value.skills | length)"' "$manifest" \
    | while IFS=$'\t' read -r key label count; do
        printf '  \033[36m%-14s\033[0m %s  \033[90m(%s skills)\033[0m\n' "$key" "$label" "$count"
      done
  echo
  info "install any preset with:  add <preset-name>"
  info "see details with:        info <preset-name>"
  rm -f "$manifest"
}

cmd_help() {
  cat <<EOF
supercharger-opencode installer

USAGE
  $0 <command> [args]

COMMANDS
  add <skill|category|preset> [...]   install skills, categories, or curated presets
  remove [--all] <skill> [...]        uninstall one, many, or all supercharger skills
  list                                show all available skills with install status
  list-categories                     show category summary
  presets                             show curated preset bundles
  info <skill|category|preset>        show details for one target
  help                                show this message

EXAMPLES
  $0 add design                       # install the design category (5 skills)
  $0 add visual                       # install the visual preset (10 skills)
  $0 add claude-design                # install one skill
  $0 add frontend devops              # install two presets at once
  $0 info visual                      # what's in the visual preset?
  $0 presets                          # see all curated bundles
  $0 remove claude-design             # uninstall one
  $0 remove --all                     # uninstall ALL supercharger skills
  $0 list                             # see every skill

CURL ONE-LINER
  curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/install.sh | bash -s -- add design

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
  presets|preset|ps) cmd_presets ;;
  info|show)        shift; cmd_info "$@" ;;
  help|--help|-h|"") cmd_help ;;
  *)                die "unknown command: $1 (try 'help')" ;;
esac
