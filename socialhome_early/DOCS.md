# Social Home (Early)

This add-on is the early-access channel for Social Home — it
carries the next release candidate so it can soak with a small
audience before being promoted to the stable add-on. Behaviour
should match the upcoming stable release; the channel exists to
catch the bugs that don't.

The behaviour is otherwise identical to the stable Social Home
add-on — same options, same storage layout, same integration
auto-discovery. The early channel ships the same
`install-integration` oneshot, which syncs
[`custom_components/socialhome`](https://github.com/social-home-io/ha-integration)
against the `ha-integration` release baked into the image at
build time (`CUSTOM_COMPONENT_VERSION`). **HACS is not required
on HAOS** and the boot path is offline-only. See the
[stable add-on docs](../socialhome/DOCS.md) for the option
reference and troubleshooting tips.

## Differences from stable

| Aspect | Stable | Early |
|---|---|---|
| socialhome version | current CalVer release | next CalVer (release candidate) |
| Slug | `socialhome` | `socialhome_early` |
| `/data` mount | `/addons_data/socialhome` | `/addons_data/socialhome_early` |
| Default `log_level` | `info` | `debug` |

The two add-ons can run side by side — they get separate
persistent volumes and slugs, but they share the same Ingress
port (8099), so the Supervisor only lets one of them be
**started** at a time.

## Reporting issues

File issues against [`social-home-io/socialhome`](https://github.com/social-home-io/socialhome/issues),
not this repo — the early add-on is just packaging.
