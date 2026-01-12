# Hytale Server Docker Image
 
🐳 Production-ready Docker image for dedicated Hytale servers.
 
**Image**: `ghcr.io/hybrowse/hytale-server`

Brought to you by [Hybrowse](https://hybrowse.gg) and the developer of [setupmc.com](https://setupmc.com).

 ## Community

 Join the **Hybrowse Discord Server** to get help and stay up to date: https://hybrowse.gg/discord

## Status

This image is currently **under active development**.
We plan to release **v0.1** on the day of the Hytale release, once we have access to the official server software and can validate that it works end-to-end.
Further improvements and follow-up releases will land in the days after.

## Documentation (start here)

- [`docs/image/quickstart.md`](docs/image/quickstart.md)
- [`docs/image/configuration.md`](docs/image/configuration.md)
- [`docs/image/backups.md`](docs/image/backups.md)

## Quickstart (Docker Compose)
 
Hytale uses **QUIC over UDP** (not TCP). Publish `5520/udp`.
 
```yaml
services:
  hytale:
    image: ghcr.io/hybrowse/hytale-server:latest
    ports:
      - "5520:5520/udp"
    volumes:
      - ./data:/data
    restart: unless-stopped
```

Start:

```bash
docker compose up -d
```

Optional: opt in to automatic download of `Assets.zip` and server files (best UX):

- Set `HYTALE_AUTO_DOWNLOAD=true`
- Follow the device-code link shown in logs on first run

Auto-download details:

- Downloader source: `https://downloader.hytale.com/hytale-downloader.zip`
- Currently supported on `linux/amd64` only

Manual provisioning (no auto-download):

- Get `Assets.zip` + the `Server/` folder via:
  - [`docs/image/server-files.md`](docs/image/server-files.md)
- Create `./data/server/`
- Put `Assets.zip` at `./data/Assets.zip`
- Copy the contents of `Server/` into `./data/server/` (at minimum `./data/server/HytaleServer.jar`)
- Start and check logs if needed:

```bash
docker compose up -d
docker compose logs -n 200 hytale
```

Next:

- [`docs/image/configuration.md`](docs/image/configuration.md)
- [`docs/image/backups.md`](docs/image/backups.md)

## First-time authentication
 
In the server console:
 
```text
/auth login device
```

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
- `docs/hytale/`: internal notes (not end-user image docs)
 
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
