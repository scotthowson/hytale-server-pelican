# Upgrades

This document describes how to upgrade the `hybrowse/hytale-server` Docker image safely.

## General upgrade guidance

- Prefer pinning a specific image tag (for example `hybrowse/hytale-server:1.2.3`) instead of using `latest`.
- Always persist `/data` if you expect your server files, universe, mods, auth state, and backups to survive restarts.
- Consider taking an out-of-band backup (for example a snapshot of the `/data` volume) before upgrading.

## Graceful shutdown: recommended grace periods

The Hytale dedicated server typically stops and flushes state quickly.
Based on observed stop times of ~5–15 seconds, a small buffer is still recommended for predictable operations, especially when using mods.

- Docker Compose: `stop_grace_period: 60s`
- Kubernetes: `terminationGracePeriodSeconds: 60`

If your host is under heavy load, or you run large universes/modpacks, consider increasing this to `90` seconds.

## Docker Compose upgrade

Typical upgrade flow:

1. Ensure your `./data:/data` volume mount is persistent.
2. Stop the container (gracefully):

   - `docker compose down`

3. Pull the new image:

   - `docker compose pull`

4. Start again:

   - `docker compose up -d`

### Note: server file updates

There are two common models:

- If you use `HYTALE_AUTO_DOWNLOAD=true`:

  - With `HYTALE_AUTO_UPDATE=true` (default), the container checks for updates on each start and downloads new server files into `/data` when an update is available.
  - With `HYTALE_AUTO_UPDATE=false`, downloads happen only when files are missing.

- If you provision server files manually:

  - Replace `/data/server/HytaleServer.jar` and `/data/Assets.zip` out-of-band.
  - This project must not redistribute proprietary server files.

## Kubernetes upgrade

### Helm

- Prefer pinning the chart/app version and the image tag.
- Upgrade by changing the image tag and running `helm upgrade`.

Recommended termination grace period:

- `terminationGracePeriodSeconds: 60`

### Kustomize

- Change the image tag in your overlay and apply.

### Notes

- If you use a PVC for `/data`, upgrades should preserve world state and authentication as long as you keep the PVC.
- If you run with ephemeral `/data` (`emptyDir`), upgrades will naturally discard state on restart.

## Downgrades / rollbacks

Rolling back the image tag is possible, but rolling back server files and world state may not be safe.
If you need reliable rollbacks, use snapshots/backups of `/data` and restore those in addition to changing the image tag.
