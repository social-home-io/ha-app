# CLAUDE.md — ha-app

Instruction file for Claude Code. Read before editing.

## What this is

Home Assistant add-on repository — packages the Social Home
Python server as two HA add-ons (stable + dev). Distributed via
the HA Supervisor's *Add-on store → Repositories*. Spec: §8 of
`spec_work.md` in the Social Home meta-repo.

## Hard rules

- **Two add-ons, one source of truth.** `socialhome/` (stable)
  and `socialhome_early/` (early-access) share their `Dockerfile`,
  `run.sh`, and TOML template. Only `config.yaml` differs —
  version (during a rollout window the two diverge briefly), slug,
  and the upstream image tag. When you change the shared script
  or the template, change it in both folders. The early-access
  channel exists so a release candidate can soak with a small
  audience before it ships to stable.
- **CalVer for both add-ons** (`2026.4.25` style — no `v` prefix,
  no `-early` suffix). The early-access add-on uses the same
  version-string format as stable; its separate slug
  (`socialhome_early`) and image tag (`socialhome_early-{arch}`)
  keep the channels distinct so the Supervisor never confuses one
  for the other. During a rollout, the early add-on may carry a
  newer CalVer than stable for the soak window.
- **`run.sh` stays minimal.** Read options with `bashio::config`,
  hand them to `tempio`, `exec` the Python server. All bootstrap
  logic (HA owner discovery, integration token, Supervisor
  discovery push) lives in `socialhome.platform.ha.HaBootstrap`
  inside the Python core — never replicate it in shell.
- **Use `tempio` for templating, not heredocs.** Heredoc
  interpolation creates injection paths when the user puts a
  closing brace in their TURN secret. `tempio` reads JSON-quoted
  values verbatim and renders Go templates.
- **Mode is always `haos` in this add-on.** The TOML template
  hard-codes `[server] mode = "haos"` and the s6 run script
  exports `SH_MODE=haos` defensively (env wins over TOML in
  `Config.from_env`). `haos` selects the Supervisor-aware adapter
  that uses the injected `SUPERVISOR_TOKEN` — the legacy `ha`
  mode talks to HA Core directly and explicitly ignores the
  Supervisor proxy, which is wrong for add-on installs. Standalone
  deployments download the Python package directly.
- **Never bake credentials into the image.** Tokens are generated
  on first boot and persisted in `/data/integration_token.txt`.
- **The add-on owns its `ha-integration` version.** `build.yaml`
  pins `CUSTOM_COMPONENT_VERSION`; the Dockerfile fetches the
  matching `socialhome.zip` from GitHub at image-build time and
  stores it under `/opt/socialhome/`. The `install-integration`
  s6 oneshot syncs `custom_components/socialhome/` against that
  zip on every boot — match → no-op, mismatch → overwrite. There
  is no network fetch on the boot path. Bumping the integration
  version means bumping `CUSTOM_COMPONENT_VERSION` in both
  `build.yaml`s; the stable / early CalVer in `config.yaml` is
  independent.

## Layout

```
ha-app/
├── repository.yaml          # repo manifest (Supervisor reads this)
├── README.md
├── LICENSE
├── socialhome/              # stable add-on
│   ├── config.yaml
│   ├── Dockerfile
│   ├── build.yaml
│   ├── run.sh
│   ├── DOCS.md
│   ├── CHANGELOG.md
│   └── rootfs/etc/socialhome.toml.gtpl
└── socialhome_early/        # early-access add-on (mirrors stable)
    └── …
```

## Releases

**No git tag is needed to ship a release.** Merging the release PR
into `main` *is* the release: `.github/workflows/builder.yml`
builds and publishes both `socialhome` and `socialhome_early`
images on every push to `main`, each read from its own add-on's
`config.yaml` CalVer. Don't cut a tag as part of a release — there
is nothing downstream that needs one.

(The workflow also matches pushes of a bare numeric tag, e.g.
`2026.4.26`, which builds+publishes `socialhome` alone. That path
is a leftover manual-rebuild escape hatch for the stable image, not
part of the normal flow — leave it alone.)

The `new-release` skill (`.claude/skills/new-release/`) drives the
whole flow: branch, version bump, changelog, PR, `addon-testing`,
then merge-and-cleanup. It stops once the branch is tidied up after
merge — there's no further "cut the tag" step to run.

## Testing

There is no Python test suite — this repo is just packaging. CI
runs the official HA add-on validator (`home-assistant/builder`)
against both add-on folders.
