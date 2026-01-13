# Quickstart

## 1. Docker Compose

Hytale uses **QUIC over UDP** (not TCP). Publish `5520/udp`.

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

> [!NOTE]
> On first run, the official downloader prints an authorization URL + device code in the logs.
> After you complete this once, credentials are stored and future runs are non-interactive.

## 2. Downloader authentication (first-time only)

Watch logs:

```bash
docker compose logs -f hytale
```

Open the URL in your browser and enter the device code. After completion, the download proceeds automatically.

On subsequent runs, this step is skipped (credentials are stored on the `/data` volume).

> [!IMPORTANT]
> **After** the server starts, you must authenticate it before players can connect.
> If you skip this step, players will see: *"Server authentication unavailable - please try again later"*

## 3. Server authentication (required for player connections)

1. Attach to the server console:

   ```bash
   docker compose attach hytale
   ```

2. Run:

   ```text
   /auth login device
   ```

3. Follow the URL + device code shown in the console.

4. If multiple profiles are shown, pick one:

   ```text
   /auth select <number>
   ```

5. Check status:

   ```text
   /auth status
   ```

Detach without stopping the server: `Ctrl-p` then `Ctrl-q`

See: [`troubleshooting.md`](troubleshooting.md)

## Done!

Players can now connect.

## Next steps

- [`configuration.md`](configuration.md) — environment variables, JVM tuning, backups
- [`troubleshooting.md`](troubleshooting.md) — common issues and fixes
- [`server-files.md`](server-files.md) — manual provisioning (if not using auto-download)
- Apple Silicon (arm64): add `platform: linux/amd64` to your Compose file, or provision files manually
