# AGENTS.md — ha-app

AI agent instruction file. Read before editing. Canonical spec:
`spec_work.md` §8 in the Social Home meta-repo.

### Architecture rules
- Two add-ons share the same `Dockerfile`, `run.sh`, and
  `rootfs/etc/social_home.toml.gtpl`. Mirror changes across
  `social_home/` (stable) and `social_home_dev/` (dev) in one
  commit.
- `run.sh` only converts options to TOML via `tempio` and `exec`s
  the Python server. Anything more (token minting, owner
  provisioning, discovery push) belongs in the Python core's
  `HaBootstrap`.
- Stable image tag = the CalVer release. Dev image tag = `main`.
- Never hand-build TOML with shell heredocs — use `tempio`.

### Versioning
- CalVer tags without a ``v`` prefix — e.g. ``2026.4.25``.
- Dev add-on's `version` is ``<stable>-dev`` so it always sorts
  ahead of stable.

### Release workflow
- Tag the stable add-on (``2026.4.26``) → builds the multi-arch
  image, pushes to ``ghcr.io/social-home-io/socialhome:2026.4.26``,
  bumps both ``config.yaml`` versions in a follow-up commit (or
  prepare them in the PR before tagging).
- Dev image rebuilds on every push to ``main``.

### File locations
- Stable add-on: `social_home/`
- Dev add-on: `social_home_dev/`
- Repo manifest: `repository.yaml`
