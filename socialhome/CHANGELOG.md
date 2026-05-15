# Changelog

## 2026.5.15

Bumps the bundled Social Home server from `2026.5.14` to `2026.5.15`;
HA integration stays at `2026.5.11.4`. DM chats gain media attachments
and hold-to-record voice notes with auto-transcripts, lazy-loaded
history with a jump-to-bottom anchor, and day separators.

## 2026.5.14

Bumps the bundled Social Home server from `2026.5.13.3` to `2026.5.14`;
HA integration stays at `2026.5.11.4`. Calendar events are now anchored
to an IANA timezone so they stay correct across DST changes and travel.

## 2026.5.13.2

Bumps the bundled Social Home server from `2026.5.13.2` to `2026.5.13.3`;
HA integration stays at `2026.5.11.4`. DM chat gets a multi-line
composer, a pinned bottom layout, and optimistic message sends.

## 2026.5.13.1

Bumps the bundled Social Home server from `2026.5.13` to `2026.5.13.2`;
HA integration stays at `2026.5.11.4`. Fixes the DM inbox so the first
chat row no longer overlaps when only a single thread is present.

## 2026.5.13

Bumps the bundled Social Home server from `2026.5.12.4` to `2026.5.13`;
HA integration stays at `2026.5.11.4`. SPA pictures are now
click-to-zoom across gallery, moments, feed, and pages.

## 2026.5.11

Initial release.

- **Custom integration is baked in.** `build.yaml` pins
  `CUSTOM_COMPONENT_VERSION`; the Dockerfile fetches the matching
  `socialhome.zip` at image-build time and the `install-integration`
  s6 oneshot syncs `/homeassistant/custom_components/socialhome/`
  against it on every boot. HACS isn't required, and a freshly-imaged
  HAOS without internet still comes up clean.
- **Discovery push.** The add-on declares the `socialhome` discovery
  service in `config.yaml` and the Python core pushes a payload to
  the Supervisor on boot — HA Core dispatches it straight to the
  integration's `async_step_hassio`.
- **Backup hooks (hot).** Supervisor `backup_pre` / `backup_post`
  call the SH server's `/api/backup/{pre,post}_backup` so the
  snapshot runs `PRAGMA wal_checkpoint(TRUNCATE)` before HA reads
  `/data` — no add-on downtime.
- **Watchdog** against `/healthz` so a hung process restarts
  automatically.
- **Ingress with streamed bodies** (`ingress_stream: true`) — the
  Supervisor hands POSTs through as a stream instead of buffering
  the full body (up to 200 MiB on a media upload) into RAM.
- **Least-privilege Supervisor token.** No `hassio_role: admin` /
  `auth_api: true` — the bootstrap resolves the HA owner via HA
  Core's `config/auth/list` WS command (through the existing HA
  proxy) instead of the Supervisor's admin-scoped REST `/auth/list`.
