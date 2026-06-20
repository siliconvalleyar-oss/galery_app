#!/bin/bash
# bump_version.sh — Increments the patch version (+0.0.1) in VERSION
# and syncs pubspec.yaml with the new version.
#
# Usage:
#   ./bump_version.sh          # bump version + update files
#   ./bump_version.sh --tag    # create git tag for current version
set -euo pipefail

cd "$(dirname "$0")"

# ── Tag-only mode ─────────────────────────────────────────────────
if [ "${1:-}" = "--tag" ]; then
  if [ ! -f VERSION ]; then
    echo "❌ VERSION file not found"
    exit 1
  fi
  current=$(tr -d ' \n' < VERSION)
  tag="v${current}"
  if git rev-parse "$tag" >/dev/null 2>&1; then
    echo "⚠️  Tag $tag already exists — skipping"
  else
    git tag -a "$tag" -m "Release $current"
    echo "🏷️  Created tag $tag"
  fi
  exit 0
fi

# ── Read current version ──────────────────────────────────────────
if [ ! -f VERSION ]; then
  echo "1.0.0" > VERSION
  echo "🆕 Created VERSION → 1.0.0"
  exit 0
fi

current=$(tr -d ' \n' < VERSION)
major=$(echo "$current" | cut -d. -f1)
minor=$(echo "$current" | cut -d. -f2)
patch=$(echo "$current" | cut -d. -f3)

major=${major:-1}
minor=${minor:-0}
patch=${patch:-0}

# ── Compute new version ───────────────────────────────────────────
new_patch=$((patch + 1))
new_version="${major}.${minor}.${new_patch}"

# ── Update VERSION ────────────────────────────────────────────────
echo "$new_version" > VERSION

# ── Sync pubspec.yaml ─────────────────────────────────────────────
if [ -f pubspec.yaml ]; then
  build_num=$(grep -E '^version:' pubspec.yaml | sed -E 's/.*\+([0-9]+).*/\1/')
  if [ -n "$build_num" ]; then
    new_line="version: ${new_version}+${build_num}"
  else
    new_line="version: ${new_version}+1"
  fi
  sed -i "s/^version:.*/${new_line}/" pubspec.yaml
  echo "📝 Updated pubspec.yaml → ${new_line}"
fi

echo "🔢 ${current} → ${new_version}"