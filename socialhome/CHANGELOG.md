# Changelog

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
