# Local development

This repository is intentionally set up so contributors can test the image locally without committing or redistributing proprietary Hytale server binaries.

## Prerequisites

- Docker
- Task (`task`): https://taskfile.dev/

## Local data directory

The default local development workflow uses a bind mount:

- `./data` (host) -> `/data` (container)

This repo already ignores `data/` via `.gitignore`.

## Manual provisioning workflow

1. Obtain `Assets.zip` and the `Server/` folder:

- [`server-files.md`](server-files.md)

2. Provision into the expected layout:

```text
./data/
  Assets.zip
  server/
    HytaleServer.jar
    ...
```

3. Start the container:

```bash
task dev:up
```

4. Follow logs:

```bash
task dev:logs
```

5. Stop/remove container:

```bash
task dev:down
```

## Opt-in auto-download workflow

If you prefer fewer manual steps, you can start the container with auto-download enabled:

```bash
task dev:up:auto
```

Notes:

- First run may require device-code authorization (watch logs).
- Credentials will be stored on the `./data` volume.
- Auto-download currently works on `linux/amd64` only.

## Useful variables

You can override these Task vars:

- `IMAGE_NAME` (default `hytale-server:local`)
- `DEV_CONTAINER_NAME` (default `hytale-server-dev`)
- `DEV_DATA_DIR` (default `./data`)
- `DEV_PORT` (default `5520`)

Example:

```bash
DEV_PORT=5521 task dev:up
```
