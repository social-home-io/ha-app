# Social Home — Home Assistant add-on repository

This repository hosts the Home Assistant add-ons for [Social
Home](https://social-home.io). Two flavours, same shape:

| Add-on | Slug | Image tag | Purpose |
|---|---|---|---|
| **Social Home** | `socialhome` | `:<release>` | Tracks tagged releases. Pick this for everyday use. |
| **Social Home (Early)** | `socialhome_early` | `:<release>` | Early-access channel — release candidates land here first so you can shake them out before they ship to the stable add-on. Same shape as stable, same release cadence; just one cut ahead. |

The two add-ons share their `Dockerfile`, `run.sh`, and TOML
template; only the version + image tag in `config.yaml` differ.

## Add the repository

In Home Assistant, open *Settings → Add-ons → Add-on store*, click
the three-dot menu, choose *Repositories*, and paste:

```
https://github.com/social-home-io/ha-app
```

Then install **Social Home** (or **Social Home (Early)**). The
add-on auto-registers the matching [Social Home HA
integration](https://github.com/social-home-io/ha-integration) on
first boot via Supervisor discovery — there is nothing to type.

## How configuration works

`run.sh` is a thin
[`bashio`](https://github.com/hassio-addons/bashio) wrapper that
forwards the user options to
[`tempio`](https://github.com/home-assistant/tempio), which
renders `socialhome.toml.gtpl` into `/data/socialhome.toml`.
The Python core then reads the rendered file. Bootstrap (admin
provisioning, integration token, discovery push) is implemented
in the core's `HaBootstrap` so `run.sh` stays minimal.

## License

[Mozilla Public License 2.0](LICENSE).
