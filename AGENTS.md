# Claude / AI Assistant Instructions
 
## Project
 
This repository builds and maintains a Docker image for the **official Hytale dedicated server**:
 
- Image: `ghcr.io/hybrowse/hytale-server`
 
## Non-negotiables
 
- Do **not** commit or embed proprietary Hytale server binaries/assets.
- Treat all authentication material as **secrets**:
  - `.hytale-downloader-credentials.json`
  - OAuth tokens
  - `HYTALE_SERVER_SESSION_TOKEN` / `HYTALE_SERVER_IDENTITY_TOKEN`
- Prefer least-privilege container defaults (avoid running as root).
 
## Quality bar
 
- Changes must be runnable and documented.
- Provide helpful startup validation and error messages.
- Avoid breaking existing users (be explicit about behavior changes).
 
## Documentation
 
- Hytale software notes live in `docs/hytale/`.
- Image documentation lives in `docs/image/`.
 
## AI Agents
 
This repository uses AI assistants (agents) to accelerate development while keeping the output **production-grade**.
 
## Principles
 
- **Security first**: treat tokens/credentials as secrets; avoid logging sensitive values.
- **Operational UX**: prefer simple configuration, clear error messages, predictable behavior.
- **Performance aware**: avoid expensive defaults; document tuning knobs.
- **Clean implementation**: do not copy/paste code from other projects.
 
## Hard constraints
 
- Do **not** add or redistribute proprietary Hytale server binaries or assets in the repository.
- Do **not** download proprietary server binaries at image build time.
- Do **not** introduce network calls that fetch untrusted code.
 
## When making changes
 
- Keep PRs small and focused.
- Update docs when behavior changes.
- Prefer safe defaults; add explicit opt-ins for risky behavior.
