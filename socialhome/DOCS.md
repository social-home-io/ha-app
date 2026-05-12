# Social Home — Home Assistant add-on

Social Home is a private, federated household social network that
runs on your Home Assistant. Once installed the add-on:

1. Drops the matching
   [Social Home HA integration](https://github.com/social-home-io/ha-integration)
   straight into `/config/custom_components/socialhome/`. The
   add-on ships a tested pair of versions (`SOCIALHOME_VERSION`
   for the server core, `CUSTOM_COMPONENT_VERSION` for the
   integration) baked into the image at build time, so the boot
   path is **offline-only** — no GitHub round-trip, works on a
   freshly-imaged HAOS without internet. **HACS is not required
   on HAOS** — the add-on owns the integration's lifecycle
   end-to-end.
2. Provisions the HA owner as the Social Home admin (no password —
   authentication is HA SSO).
3. Mints a long-lived API token for the integration.
4. Pushes a Supervisor discovery record so the integration shows
   up under *Settings → Devices & services* with one click.

After install, refresh *Settings → Devices & services* and click
**Configure** on the Social Home discovery card. The integration
takes care of everything else.

## Options

| Option | Type | Description |
|---|---|---|
| `log_level` | enum | `trace`, `debug`, `info`, `warning`, `error`, `fatal`. Defaults to `info`. |
| `ai_task_entity_id` | string | HA `ai_task.*` entity (e.g. `ai_task.openai`) used by the calendar photo importer and any future AI-task feature. Empty leaves the AI surface off — the SPA hides AI affordances instead of failing at use-time. |
| `stt_entity_id` | string | HA `stt.*` entity used for in-app voice-to-text. Empty leaves `Capability.STT` off so the SPA hides the mic button. |

## Storage

The add-on persists everything to `/data` (mapped to
`/addons_data/socialhome` on the host). SQLite, media files, and
the integration token survive add-on updates.

## Backups

`/data` is included in any HA Supervisor full or partial backup
that selects the *Social Home* add-on. The add-on keeps running
during the snapshot (`backup: hot`); the Supervisor calls
`/etc/socialhome/backup-pre.sh` immediately before the copy,
which POSTs to the SH server's `/api/backup/pre_backup`. That
endpoint runs `PRAGMA wal_checkpoint(TRUNCATE)` so any pages
sitting in `socialhome.db-wal` are folded into `socialhome.db`
before bytes leave the container — the archive captures every
durable write up to the snapshot moment without taking the
add-on offline.

## Network

Web UI + API are exposed through HA Ingress on port `8099` —
there is no separate hostname / port to publish.

## Logs

Inspect with the regular *Add-on → Log* tab in HA, or via
`bashio::log` from the host shell. Increase verbosity with the
`log_level` option.

## Troubleshooting

- **The integration doesn't auto-discover** — restart the add-on;
  discovery is pushed on every boot.
- **The custom_component wasn't updated** — the `install-integration`
  oneshot runs at every add-on start and syncs the
  `custom_components/socialhome/` folder against the `ha-integration`
  release baked into the image. When the manifest on disk already
  matches `CUSTOM_COMPONENT_VERSION` the oneshot is a no-op; otherwise
  it overwrites the folder from the bundled zip. The `Log` tab
  shows the resolved version every boot.
- **`401 Unauthorized` from the integration** — delete
  `/data/integration_token.txt` and restart the add-on. A fresh
  token is generated on first start; the integration's re-auth
  flow then prompts for it.
- **Federation peers can't reach you** — check `external_url` /
  Nabu Casa Remote UI in *Settings → Network*; the integration
  pushes whatever HA reports there to Social Home.
