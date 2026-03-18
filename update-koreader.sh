#!/bin/bash
# update-koreader.sh - Updates Dockerfile with latest KOReader URL and pushes to GitHub
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKERFILE="$REPO_DIR/Dockerfile"

# Force sync with remote before doing anything
cd "$REPO_DIR"
git fetch origin main
git reset --hard origin/main

BASE_URL="https://ota.koreader.rocks/"
LATEST_NIGHTLY_URL="${BASE_URL}koreader-linux-arm64-latest-nightly"
PATTERN='^koreader-linux-arm64-v[0-9]{4}\.[0-9]{2}-[0-9]+-g[0-9a-f]+_[0-9]{4}-[0-9]{2}-[0-9]{2}\.tar\.xz$'

get_latest_url() {
  local latest_path

  latest_path="$(curl -fsSL "$LATEST_NIGHTLY_URL" | tr -d '\r\n')"

  if [[ -z "${latest_path:-}" ]]; then
    echo "Error: No nightly filename returned from $LATEST_NIGHTLY_URL" >&2
    exit 1
  fi

  if [[ ! "$latest_path" =~ $PATTERN ]]; then
    echo "Error: Unexpected nightly filename from $LATEST_NIGHTLY_URL: $latest_path" >&2
    exit 1
  fi

  printf '%s%s\n' "$BASE_URL" "$latest_path"
}

LATEST_URL="$(get_latest_url)"

CURRENT_URL="$(grep -oP '(?<=ARG KOREADER_URL=).+' "$DOCKERFILE" || true)"

if [[ "$CURRENT_URL" == "$LATEST_URL" ]]; then
  echo "Already up to date."
  exit 0
fi

echo "Updating KOReader URL:"
echo "  Old: ${CURRENT_URL:-<none>}"
echo "  New: $LATEST_URL"

# Extract version string (e.g., v2026.03-1-gbb04cb8a1)
VERSION="$(echo "$LATEST_URL" | grep -oP 'v[0-9]+\.[0-9]+(-[0-9]+-g[0-9a-f]+)?')"

sed -i "s|^ARG KOREADER_URL=.*$|ARG KOREADER_URL=$LATEST_URL|" "$DOCKERFILE"

cd "$REPO_DIR"
git add Dockerfile
git commit -m "$VERSION"
git push origin main

echo "Done!"
