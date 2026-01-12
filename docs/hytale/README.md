# Hytale Server Software (Docs)

This section contains **internal reference notes** about the official Hytale dedicated server.

These pages are used as a development aid for this repository and are **not** the primary end-user documentation for the Docker image.
If you are looking for image usage docs, use:

- [`docs/image/`](../image/)

## Key facts (from official docs)

- **Java:** Hytale servers require **Java 25**.
- **CPU/RAM:** Minimum **4GB RAM**; x64 and arm64 are supported.
- **Networking:** Client connections use **QUIC over UDP**.
  - Default bind: `0.0.0.0:5520`.
- **Server files:** You need the server binaries plus **`Assets.zip`**.
- **Authentication:** Servers must be authenticated before they can accept player connections.

## Pages

- `server-setup.md` — Java + getting server files
- `running.md` — launch, ports, firewall, file layout
- `tips-and-tricks.md` — mods, AOT cache, Sentry, view distance
- `multiserver-architecture.md` — referral, redirects, fallbacks, proxy notes
- `misc-details.md` — JVM args, protocol updates, config file behavior
- `future-additions.md` — upcoming official platform features (discovery, parties, APIs)
- `server-provider-auth.md` — automated auth for hosting providers (advanced)
