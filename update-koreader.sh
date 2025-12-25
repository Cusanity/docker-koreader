#!/bin/bash
# update-koreader.sh - Updates Dockerfile with latest KOReader URL and pushes to GitHub
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKERFILE="$REPO_DIR/Dockerfile"

# Fetch latest URL from n8n webhook
LATEST_URL=$(curl -s "https://n8n.cusanity.synology.me/webhook/ko" | grep -oP '(?<="latestUrl":")[^"]+')

if [ -z "$LATEST_URL" ]; then
    echo "Error: Failed to get latestUrl from webhook"
    exit 1
fi

# Get current URL
CURRENT_URL=$(grep -oP '(?<=ARG KOREADER_URL=).+' "$DOCKERFILE")

if [ "$CURRENT_URL" = "$LATEST_URL" ]; then
    echo "Already up to date."
    exit 0
fi

echo "Updating KOReader URL:"
echo "  Old: $CURRENT_URL"
echo "  New: $LATEST_URL"

# Update Dockerfile
sed -i "s|ARG KOREADER_URL=.*|ARG KOREADER_URL=$LATEST_URL|" "$DOCKERFILE"

# Commit and push
cd "$REPO_DIR"
git add Dockerfile
git commit -m "chore: update KOReader"
git push origin main

echo "Done!"
