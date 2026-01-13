# Hytale Server Docker Image
 
🐳 Production-ready Docker image for dedicated Hytale servers.
 
**Image (Docker Hub)**: `hybrowse/hytale-server`
**Mirror (GHCR)**: `ghcr.io/hybrowse/hytale-server`

Brought to you by [Hybrowse](https://hybrowse.gg) and the developer of [setupmc.com](https://setupmc.com).

 ## Community

 Join the **Hybrowse Discord Server** to get help and stay up to date: https://hybrowse.gg/discord

## Status

This image is currently **under active development**.
We plan to release **v0.1** on the day of the Hytale release, once we have access to the official server software and can validate that it works end-to-end.
Further improvements and follow-up releases will land in the days after.

## Quickstart

```yaml
services:
  hytale:
    image: hybrowse/hytale-server:latest
    environment:
      HYTALE_AUTO_DOWNLOAD: "true"
    ports:
      - "5520:5520/udp"
    volumes:
      - ./data:/data
    tty: true
    stdin_open: true
    restart: unless-stopped
```

```bash
docker compose up -d
```

> [!IMPORTANT]
> **Two authentication steps required:**
>
> 1. **Downloader auth** (first run): follow the URL + device code in the logs to download server files
> 2. **Server auth** (after startup): run `/auth login device` in the server console before players can connect

Full guide: [`docs/image/quickstart.md`](docs/image/quickstart.md)

Troubleshooting: [`docs/image/troubleshooting.md`](docs/image/troubleshooting.md)

## Documentation

- [`docs/image/quickstart.md`](docs/image/quickstart.md) — start here
- [`docs/image/configuration.md`](docs/image/configuration.md) — environment variables, JVM tuning
- [`docs/image/troubleshooting.md`](docs/image/troubleshooting.md) — common issues
- [`docs/image/backups.md`](docs/image/backups.md) — backup configuration
- [`docs/image/server-files.md`](docs/image/server-files.md) — manual provisioning (arm64, etc.)

## Why this image

- **Security-first defaults** (least privilege; credentials/tokens treated as secrets)
- **Operator UX** (clear startup validation and actionable errors)
- **Performance-aware** (sane JVM defaults; optional AOT cache usage)
- **Predictable operations** (documented data layout and upgrade guidance)

## Java

Hytale requires **Java 25**.
This image uses **Adoptium / Eclipse Temurin 25**.

## Planned features

See [`ROADMAP.md`](ROADMAP.md) for details. Highlights:

- **MVP**: non-root runtime, startup validation, minimal healthcheck, clear docs
- **Operations**: safer upgrades, backup guidance, better logging ergonomics
- **Observability**: metrics hooks / exporter guidance
- **Provider-grade**: non-interactive auth flows and fleet patterns
 
## Documentation
 
- [`docs/image/`](docs/image/): Image usage & configuration
- [`docs/hytale/`](docs/hytale/): internal notes (not end-user image docs)
 
## Contributing & Security
 
- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- [`SECURITY.md`](SECURITY.md)

## Local verification

You can build and run basic container-level validation tests locally:

```bash
task verify
```

Install Task:

- https://taskfile.dev/
 
## License
 
See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).
