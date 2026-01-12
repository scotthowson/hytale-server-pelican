# Configuration

## Java runtime

The official Hytale server requires Java 25.
This image uses **Adoptium / Eclipse Temurin 25** (`eclipse-temurin:25-jre`).

## Opt-in auto-download (best UX)

If `HYTALE_AUTO_DOWNLOAD=true` and `Assets.zip` / `HytaleServer.jar` are missing, the container will:

- download the official Hytale Downloader from `https://downloader.hytale.com/`
- run it using the OAuth device-code flow
- store downloader credentials on the `/data` volume
- extract `Assets.zip` to `/data/Assets.zip`
- extract `Server/` contents to `/data/server/`

Credentials are stored as:

- `/data/.hytale-downloader-credentials.json`

If that file already exists (for example from a previous run), downloads become non-interactive.

For safety, `HYTALE_DOWNLOADER_URL` is restricted to `https://downloader.hytale.com/`.

Current limitation:

- Auto-download is supported on `linux/amd64` only, because the official downloader archive currently does not include a `linux/arm64` binary.
- On `linux/arm64`, you must provide the server files and `Assets.zip` manually.

## Environment variables

| Variable | Default | Description |
|---|---:|---|
| `HYTALE_SERVER_JAR` | `/data/server/HytaleServer.jar` | Path to `HytaleServer.jar` inside the container. |
| `HYTALE_ASSETS_PATH` | `/data/Assets.zip` | Path to `Assets.zip` inside the container. |
| `HYTALE_AOT_PATH` | `/data/server/HytaleServer.aot` | Path to the AOT cache file. |
| `HYTALE_BIND` | `0.0.0.0:5520` | Bind address for QUIC/UDP. |
| `HYTALE_AUTH_MODE` | `authenticated` | Authentication mode (`authenticated` or `offline`). |
| `HYTALE_DISABLE_SENTRY` | `false` | If `true`, passes `--disable-sentry`. |
| `HYTALE_ENABLE_BACKUP` | `false` | If `true`, passes `--backup`. |
| `HYTALE_BACKUP_DIR` | *(empty)* | Passed as `--backup-dir`. |
| `HYTALE_BACKUP_FREQUENCY_MINUTES` | *(empty)* | Passed as `--backup-frequency`. |
| `HYTALE_SERVER_SESSION_TOKEN` | *(empty)* | Passed as `--session-token` (**secret**). |
| `HYTALE_SERVER_IDENTITY_TOKEN` | *(empty)* | Passed as `--identity-token` (**secret**). |
| `HYTALE_AUTO_DOWNLOAD` | `false` | If `true`, downloads server files and `Assets.zip` via the official Hytale Downloader when missing. |
| `HYTALE_DOWNLOADER_URL` | `https://downloader.hytale.com/hytale-downloader.zip` | Official downloader URL (must start with `https://downloader.hytale.com/`). |
| `HYTALE_DOWNLOADER_DIR` | `/data/.hytale-downloader` | Directory where the image stores the downloader binary. |
| `HYTALE_DOWNLOADER_PATCHLINE` | *(empty)* | Optional downloader patchline (e.g. `pre-release`). |
| `HYTALE_DOWNLOADER_SKIP_UPDATE_CHECK` | `true` | If `true`, passes `-skip-update-check` to reduce network/variability during automation. |
| `HYTALE_DOWNLOADER_CREDENTIALS_SRC` | *(empty)* | Optional path to a mounted credentials file to seed `/data/.hytale-downloader-credentials.json`. |
| `HYTALE_GAME_ZIP_PATH` | `/data/game.zip` | Where the downloader stores the downloaded game package zip. |
| `HYTALE_KEEP_GAME_ZIP` | `false` | If `true`, keep the downloaded game zip after extraction. |
| `JVM_XMS` | *(empty)* | Passed as `-Xms...` (initial heap). |
| `JVM_XMX` | *(empty)* | Passed as `-Xmx...` (max heap). |
| `JVM_EXTRA_ARGS` | *(empty)* | Extra JVM args appended to the `java` command. |
| `ENABLE_AOT` | `auto` | `auto\|true\|false` (controls `-XX:AOTCache=...`). |
| `EXTRA_SERVER_ARGS` | *(empty)* | Extra server args appended at the end. |

## Examples

### Change bind address / port

```yaml
services:
  hytale:
    environment:
      HYTALE_BIND: "0.0.0.0:5520"
```

### Disable Sentry

```yaml
services:
  hytale:
    environment:
      HYTALE_DISABLE_SENTRY: "true"
```

### JVM heap tuning

```yaml
services:
  hytale:
    environment:
      JVM_XMS: "2G"
      JVM_XMX: "6G"
```

### AOT cache

- `ENABLE_AOT=auto`: enables AOT only when the cache file exists.
- `ENABLE_AOT=true`: requires the cache file to exist and fails fast otherwise.

### Non-interactive auto-download (seed credentials)

If you already have `.hytale-downloader-credentials.json`, you can mount it read-only and seed it:

```yaml
services:
  hytale:
    secrets:
      - hytale_downloader_credentials
    environment:
      HYTALE_AUTO_DOWNLOAD: "true"
      HYTALE_DOWNLOADER_CREDENTIALS_SRC: "/run/secrets/hytale_downloader_credentials"

secrets:
  hytale_downloader_credentials:
    file: ./secrets/.hytale-downloader-credentials.json
```

## Related docs

- [`server-files.md`](server-files.md)
- [`backups.md`](backups.md)
