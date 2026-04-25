# CLAUDE.md — ha-app

Instruction file for Claude Code. Read before editing.

## What this is

Home Assistant add-on repository — packages the Social Home
Python server as two HA add-ons (stable + dev). Distributed via
the HA Supervisor's *Add-on store → Repositories*. Spec: §8 of
`spec_work.md` in the Social Home meta-repo.

## Hard rules

- **Two add-ons, one source of truth.** `social_home/` (stable)
  and `social_home_dev/` (dev) share their `Dockerfile`,
  `run.sh`, and TOML template. Only `config.yaml` differs —
  version, slug, and the upstream image tag. When you change the
  shared script or the template, change it in both folders.
- **CalVer for the stable add-on** (`2026.4.25` style — no `v`
  prefix). The dev add-on uses `2026.4.25-dev` so the Supervisor
  always treats it as ahead of the stable channel.
- **`run.sh` stays minimal.** Read options with `bashio::config`,
  hand them to `tempio`, `exec` the Python server. All bootstrap
  logic (HA owner discovery, integration token, Supervisor
  discovery push) lives in `socialhome.platform.ha.HaBootstrap`
  inside the Python core — never replicate it in shell.
- **Use `tempio` for templating, not heredocs.** Heredoc
  interpolation creates injection paths when the user puts a
  closing brace in their TURN secret. `tempio` reads JSON-quoted
  values verbatim and renders Go templates.
- **Mode is always `ha` in this add-on.** The TOML template
  hard-codes `[server] mode = "ha"`; standalone deployments
  download the Python package directly.
- **Never bake credentials into the image.** Tokens are generated
  on first boot and persisted in `/data/integration_token.txt`.

## Layout

```
ha-app/
├── repository.yaml          # repo manifest (Supervisor reads this)
├── README.md
├── LICENSE
├── social_home/             # stable add-on
│   ├── config.yaml
│   ├── Dockerfile
│   ├── build.yaml
│   ├── run.sh
│   ├── DOCS.md
│   ├── CHANGELOG.md
│   └── rootfs/etc/social_home.toml.gtpl
└── social_home_dev/         # dev add-on (mirrors stable)
    └── …
```

## Releases

CalVer git tags drive the stable channel:

```sh
git tag 2026.4.26
git push origin 2026.4.26
```

The release workflow rebuilds the image for every supported arch
and publishes to `ghcr.io/social-home-io/socialhome` with the tag
as the image tag. The dev add-on always rebuilds from `main` on
every push and is published to the same registry under `:main`.

## Testing

There is no Python test suite — this repo is just packaging. CI
runs the official HA add-on validator (`home-assistant/builder`)
against both add-on folders.
