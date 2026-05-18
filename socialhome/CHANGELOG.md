# Changelog

## 2026.5.18.2

Bumps the bundled Social Home server from `2026.5.18.1` to
[`2026.5.18.2`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.18.2);
HA integration stays at `2026.5.11.4`. Routes the pairing
peer-accept/confirm step through the federation inbox URL so the
handshake completes under HAOS, and auto-prunes expired pending
handshakes plus orphaned `PENDING` instances.

## 2026.5.18.1

Bumps the bundled Social Home server from `2026.5.18` to
[`2026.5.18.1`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.18.1);
HA integration stays at `2026.5.11.4`. Fixes the HA/HAOS pairing
QR to append `/api/socialhome/inbox` to the pushed base URL, and
restores the unusable +New store… input in the shopping store
picker on desktop.

## 2026.5.18

Bumps the bundled Social Home server from `2026.5.17` to
[`2026.5.18`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.18);
HA integration stays at `2026.5.11.4`. Tasks now group by status
with colored sections and drag-and-drop reordering, and pairing
falls back to a `socialhome://` copy/paste link when scanning a QR
isn't an option.

## 2026.5.17

Bumps the bundled Social Home server from `2026.5.16` to
[`2026.5.17`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.17);
HA integration stays at `2026.5.11.4`. Shopping list now lets you
drag items between stores with a one-tap store picker, and DM
media, image processing, and schedulers no longer block the event
loop on large attachments.

## 2026.5.16

Bumps the bundled Social Home server from `2026.5.15` to `2026.5.16`;
HA integration stays at `2026.5.11.4`. DM bubbles gain a long-press
action menu with swipe-to-reply and per-message reactions, and the
SPA now prompts the user to reload when a new deploy is detected.

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
