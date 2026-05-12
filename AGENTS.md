# AGENTS.md — ha-app

AI agent instruction file. Read before editing. Canonical spec:
`spec_work.md` §8 in the Social Home meta-repo.

### Architecture rules
- Two add-ons share the same `Dockerfile`, `run.sh`, and
  `rootfs/etc/socialhome.toml.gtpl`. Mirror changes across
  `socialhome/` (stable) and `socialhome_early/` (early-access)
  in one commit.
- `run.sh` only converts options to TOML via `tempio` and `exec`s
  the Python server. Anything more (token minting, owner
  provisioning, discovery push) belongs in the Python core's
  `HaBootstrap`.
- Stable + early image tags = the CalVer in `config.yaml`. During
  a rollout the early add-on may carry a newer CalVer than stable
  for the soak window.
- Never hand-build TOML with shell heredocs — use `tempio`.

### Versioning
- CalVer tags without a ``v`` prefix — e.g. ``2026.4.25``.
- Both add-ons use the same CalVer format (no ``-early`` /
  ``-dev`` suffix). The early channel's lead over stable is
  expressed by carrying a newer CalVer in its ``config.yaml``
  during the rollout window.

### Release workflow
- Bump ``socialhome_early/config.yaml`` to the next CalVer, soak
  the build with the early audience.
- Once it's clean, bump ``socialhome/config.yaml`` to the same
  CalVer and tag the repo — that drives the stable build/push to
  ``ghcr.io/social-home-io/ha-app/social_home-{arch}``.

### File locations
- Stable add-on: `socialhome/`
- Early-access add-on: `socialhome_early/`
- Repo manifest: `repository.yaml`
