# Roadmap
 
This roadmap focuses on delivering a **secure, fast, and easy-to-operate** Docker image for the official Hytale dedicated server.
 
## Guiding principles
 
- **Security**: least-privilege defaults, safe handling of credentials/tokens, no accidental binary redistribution
- **Performance**: sane JVM defaults, optional AOT cache usage, practical tuning guidance
- **Speed**: quick startup, repeatable upgrades, minimal friction
- **UX**: simple configuration, clear docs, helpful error messages
 
## v0.1 — MVP (single-server)
 
- Run the Hytale server from a persistent data volume (e.g. `./data:/data`)
- Clear validation & error messages when server files / `Assets.zip` are missing
- Networking defaults:
  - UDP/QUIC on `5520/udp`
  - configurable bind address/port
- Environment-variable configuration mapping to common server flags:
  - assets path
  - auth mode (authenticated/offline)
  - disable Sentry flag
  - backup flags (enable/dir/frequency)
  - JVM heap (Xms/Xmx) + extra JVM args
  - extra server args passthrough
- Run as **non-root** by default and support configurable UID/GID for file permission alignment
- Graceful shutdown behavior with configurable stop/grace period
- Basic healthcheck (process-level) with a documented way to disable it
- Documentation:
  - Compose quickstart
  - firewall/port-forwarding notes (UDP)
 
## v0.2 — Operations & upgrades
 
- Optional server file download/update via the official Downloader CLI (where supported)
- Upgrade guidance that reflects strict client/server protocol matching
- Backup/restore playbook (including “offline” file operations)
- Timezone configuration for consistent timestamps in logs/backups
- Troubleshooting commands and diagnostics output (versions, config paths, bind info)
 
## v0.3 — Observability
 
- Metrics integration guide (Prometheus exporter plugin usage)
- Operational recommendations:
  - log management/retention
  - capacity planning notes (view distance, heap sizing)
 
## v1.0 — Provider-grade features
 
- Non-interactive authentication support for hosting providers (session/identity token injection)
- Safer secret handling patterns (Docker secrets / Kubernetes secrets guidance)
- Hardening guidance:
  - read-only root filesystem
  - capability dropping
  - seccomp/profile recommendations
