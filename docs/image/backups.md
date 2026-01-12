# Backups

## Overview

The Hytale dedicated server supports an internal backup mechanism.
This image exposes it via environment variables and recommends storing backups on a **separate volume**.

Until we have more operational experience with the official server, treat backup outputs as **opaque artifacts**.

## Enable backups (Docker Compose)

```yaml
services:
  hytale:
    image: ghcr.io/hybrowse/hytale-server:latest
    ports:
      - "5520:5520/udp"
    volumes:
      - ./data:/data
      - ./backups:/backups
    environment:
      HYTALE_ENABLE_BACKUP: "true"
      HYTALE_BACKUP_DIR: "/backups"
      HYTALE_BACKUP_FREQUENCY_MINUTES: "60"
    restart: unless-stopped
```

## Recommended storage patterns

- Keep `/data` (server state) and backups on different volumes/paths.
- Consider syncing `./backups` to offsite storage (object storage, rsync to another host, etc.).

## Notes

- If you change backup paths, ensure the container user can write to them.
- Backup settings map directly to the server flags (`--backup`, `--backup-dir`, `--backup-frequency`).

## Related docs

- [`quickstart.md`](quickstart.md)
- [`configuration.md`](configuration.md)
