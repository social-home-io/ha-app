# Social Home — Home Assistant add-on

Social Home is a private, federated household social network that
runs on your Home Assistant. Once installed the add-on:

1. Provisions the HA owner as the Social Home admin (no password —
   authentication is HA SSO).
2. Mints a long-lived API token for the matching
   [Social Home HA integration](https://github.com/social-home-io/ha-integration).
3. Pushes a Supervisor discovery record so the integration shows
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
`/addons_data/social_home` on the host). SQLite, media files, and
the integration token survive add-on updates.

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
- **`401 Unauthorized` from the integration** — delete
  `/data/integration_token.txt` and restart the add-on. A fresh
  token is generated on first start; the integration's re-auth
  flow then prompts for it.
- **Federation peers can't reach you** — check `external_url` /
  Nabu Casa Remote UI in *Settings → Network*; the integration
  pushes whatever HA reports there to Social Home.
