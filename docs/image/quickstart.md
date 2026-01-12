# Quickstart

## Docker Compose

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

## Required files

This image runs the official Hytale dedicated server binaries from a persistent volume.

Expected layout:

- `./data/Assets.zip`
- `./data/server/HytaleServer.jar`

If those files are missing, the container will exit with a clear error message.

### Best UX: opt-in auto-download

If you prefer fewer manual steps, you can opt in to automatic download & extraction:

```yaml
services:
  hytale:
    environment:
      HYTALE_AUTO_DOWNLOAD: "true"
```

On first run, the official downloader will print an authorization URL + device code.
After you complete the browser flow, the container will download the game package and extract:

- `Assets.zip` to `/data/Assets.zip`
- `Server/` contents to `/data/server/`

Watch logs during first-time auth:

```bash
docker compose logs -f hytale
```

Downloader credentials are stored on the `/data` volume as:

- `/data/.hytale-downloader-credentials.json`

On subsequent runs, the download flow should be non-interactive.

Auto-download details:

- The downloader is fetched from `https://downloader.hytale.com/hytale-downloader.zip`.
- Currently, auto-download is supported on `linux/amd64` only.

### Manual provisioning (no auto-download)

If you prefer to skip auto-download, you can provide the files yourself.

To obtain `Assets.zip` and the `Server/` folder, follow:

- [`server-files.md`](server-files.md)

1. Create the expected folders:

   - `./data/`
   - `./data/server/`

2. Place these files:

   - `Assets.zip` at `./data/Assets.zip`
   - contents of the `Server/` folder at `./data/server/` (at minimum `HytaleServer.jar` at `./data/server/HytaleServer.jar`)

3. Start the container:

   ```bash
   docker compose up -d
   ```

4. If the container exits, check logs for a precise missing-file path:

   ```bash
   docker compose logs -n 200 hytale
   ```

See:

- [`server-files.md`](server-files.md)

## Java runtime

Hytale requires Java 25.
This image uses **Adoptium / Eclipse Temurin 25**.

## First-time authentication

In the server console:

```text
/auth login device
```

## Notes

- Keep `Assets.zip` and server files in sync when updating.
- Do not log or commit any credentials/tokens.

See also:

- [`configuration.md`](configuration.md)
- [`backups.md`](backups.md)
- [`development.md`](development.md)
