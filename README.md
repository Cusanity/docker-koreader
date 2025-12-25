# Docker KOReader (ARM64)

> **Fork of [zephyros-dev/docker-koreader](https://github.com/zephyros-dev/docker-koreader)**

[![Build](https://github.com/cusanity/docker-koreader/actions/workflows/build.yaml/badge.svg?branch=main)](https://github.com/cusanity/docker-koreader/actions/workflows/build.yaml)
[![Latest](https://ghcr-badge.egpl.dev/cusanity/koreader/latest_tag?color=%2344cc11&ignore=latest&label=Latest&trim=)](https://github.com/cusanity/docker-koreader/pkgs/container/koreader)

KOReader in a Docker container, accessible via browser. Tested on **Raspberry Pi 4**.

## Why This Fork?

This fork is tailored for ARM64 (Raspberry Pi 4) with the following changes:

| Feature | Original | This Fork |
|---------|----------|-----------|
| **Architecture** | amd64 + arm64 | arm64 only |
| **Base Image** | Debian + Fedora options | Ubuntu Noble ARM64 only |
| **KOReader Updates** | Renovate (GitHub releases) | Custom script (OTA nightly builds) |
| **Autostart** | Sometimes broken | Force-enabled on every boot |

### Key Changes

- **Simplified Dockerfile** - Single ARM64 stage, no multi-arch complexity
- **Custom update script** (`update-koreader.sh`) - Fetches latest KOReader from OTA server
- **Fixed autostart** - KOReader always launches on container start
- **Removed** - Fedora support, pre-commit hooks, test workflow

## Installation

1. Create a `docker-compose.yaml`:

   ```yaml
   services:
     koreader:
       image: ghcr.io/cusanity/koreader:latest
       ports:
         - "3000:3000"
       volumes:
         - ./config:/config
   ```

2. Start the container:

   ```bash
   docker-compose up -d
   ```

3. Open `http://localhost:3000` in your browser.

## Building Locally

```bash
docker buildx build --platform linux/arm64 -t koreader:local --load .
```

## Configuration

- Based on [linuxserver/baseimage-selkies](https://github.com/linuxserver/docker-baseimage-selkies)
- KOReader config: `/config/.config/koreader` inside the container

## Updating KOReader

Run the update script (requires git credentials configured):

```bash
./update-koreader.sh
```

This fetches the latest OTA build, updates the Dockerfile, and pushes to trigger a new image build.
