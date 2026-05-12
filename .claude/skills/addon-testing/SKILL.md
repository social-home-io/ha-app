---
name: addon-testing
description: End-to-end test the socialhome / socialhome_early add-ons against a real Home Assistant Supervisor running inside this devcontainer — build, install, start, and tail logs, then hand off to the user for visual verification from outside the container.
---

# addon-testing

Run the socialhome add-on end to end inside the devcontainer's
Supervisor sandbox and stream its logs so you can confirm the build
is healthy before the user opens it in a browser.

## When to use

After editing anything under `socialhome/` or `socialhome_early/`
— Dockerfile, run/finish scripts, config.yaml, the TOML template,
the install-integration oneshot, etc. The devcontainer ships
`supervisor_run` for exactly this loop; this skill formalises the
order of operations.

## Prerequisites

- Running inside the `ghcr.io/home-assistant/devcontainer:5-apps`
  devcontainer (the `.devcontainer/devcontainer.json` in this repo).
- Workspace mounted at `/mnt/supervisor/addons/local/ha-app` — that
  path is fixed by the devcontainer config.
- Docker available on the host (devcontainer runs with
  `--privileged`).

## Steps

### 1 — Start the Supervisor

```sh
supervisor_run &
```

The VS Code task **"Start Home Assistant"** (`.vscode/tasks.json`)
runs the same command. Wait for `ha su info` to stop returning
`System is not ready` — typically ~1–3 minutes on first boot while
the supervisor pulls plugin images and HA Core.

```sh
until ha su info >/dev/null 2>&1; do sleep 5; done
```

### 1a — Onboard Home Assistant (one-time, owner user)

A freshly-pulled HA Core image has no owner user, so `auth/list`
returns an empty set and the add-on's `HaBootstrap` logs *"could
not determine HA owner — skipping"* and gives up before pushing
discovery. Onboard once with a known credential so:

* the bootstrap finds an owner and pushes discovery,
* the same login works for the human visual test in step 8.

Wait for the HA Core landingpage to come up (`ha core info`
returns a populated payload), then POST the onboarding payload
through the supervisor's HA proxy:

```sh
until ha core info --raw-json 2>/dev/null | jq -e '.data.version' >/dev/null; do sleep 5; done

curl -fsS -X POST http://172.30.32.1:8123/api/onboarding/users \
  -H 'Content-Type: application/json' \
  -d '{
    "client_id":  "https://ha-app.local/",
    "name":       "Social Home Test",
    "username":   "socialhome",
    "password":   "social_home",
    "language":   "en"
  }' | jq
```

Defaults:
| Field | Value |
|---|---|
| Username | `socialhome` |
| Password | `social_home` |

After this returns 200, `ha core restart` once so the new user is
hot in HA's auth provider, then carry on. If the call returns
*"User step already done"* the instance was already onboarded —
move on to step 2.

### 2 — Expose the add-on subdirs as local add-ons

Supervisor scans direct children of `/data/addons/local/` for
`config.yaml`. The repo root sits one level deeper, so symlink each
add-on into place:

```sh
sudo ln -sf /data/addons/local/ha-app/socialhome /mnt/supervisor/addons/local/socialhome
sudo ln -sf /data/addons/local/ha-app/socialhome_early /mnt/supervisor/addons/local/socialhome_early
ha store reload
ha store apps info local_socialhome --raw-json | jq '.data.addons[] | select(.slug=="local_socialhome")'
```

`build: true` in the output confirms Supervisor will build locally
when the published image is unavailable.

### 3 — Force a local build (private image fallback)

The published image at `ghcr.io/social-home-io/ha-app/socialhome-*`
is private. To make Supervisor build from the Dockerfile in this
checkout, remove the `image:` line from `socialhome/config.yaml`
for the duration of the test, then `ha store reload`. Restore it
before committing.

```sh
sed -i.bak '/^image:/d' socialhome/config.yaml
ha store reload
```

### 4 — Install + start

```sh
ha addons install local_socialhome   # builds the image (~3-5 min on first build)
ha addons start  local_socialhome
```

Build progress is visible on the supervisor logs:

```sh
docker logs -f hassio_supervisor 2>&1 | grep -E 'socialhome|Build|denied|ERROR'
```

…and on the buildkit container while it's alive:

```sh
docker logs -f addon_builder_local_socialhome
```

### 5 — Stream the add-on logs

```sh
ha addons logs local_socialhome --follow
```

Healthy startup looks like:

```
s6-rc: info: service init-config: starting
[..:..:..] INFO: Rendering /data/social_home.toml...
[..:..:..] INFO: Configuration written to /data/social_home.toml
s6-rc: info: service install-integration: starting
[..:..:..] INFO: install-integration: checking social-home-io/ha-integration...
[..:..:..] INFO: install-integration: socialhome <version> installed at /homeassistant/custom_components/socialhome
s6-rc: info: service socialhome: starting
[..:..:..] INFO: Starting Social Home...
INFO:__main__:socialhome: starting up (mode=ha)
```

Failure modes to grep for:
- `ModuleNotFoundError: No module named 'social_home'` — the run
  script is using the underscore typo; module is `socialhome`.
- `s6-test: No such file or directory` — `finish` script needs
  `eltest`, not `s6-test`.
- `Can't install ghcr.io/...: denied` — image is private; fall
  back to step 3 (local build).
- `install-integration: unable to reach GitHub` — non-fatal, the
  longrun still starts.

Also check the watchdog by hitting `/healthz` from inside the
container network:

```sh
docker exec hassio_supervisor curl -sS http://addon_local_socialhome:8099/healthz | jq
```

### 6 — Iterate

After editing source files, the fast path is `rebuild` (skips the
store-reload + reinstall dance):

```sh
ha addons rebuild local_socialhome
ha addons restart local_socialhome
```

Use `uninstall` only when changing fields that Supervisor reads
once at install (e.g. `map`, `ingress_port`, `watchdog`).

### 7 — Verify the HA-side integration

The `install-integration` oneshot dropped
`custom_components/socialhome/` into the HA config dir; the longrun
then triggered Supervisor discovery via `HaBootstrap`. Confirm the
HA side actually picked it up before handing off:

```sh
# Custom component is on disk and the version matches the latest
# release the oneshot resolved.
docker exec homeassistant cat /config/custom_components/socialhome/manifest.json | jq

# HA has to be restarted (or never started before) to pick up a
# new custom_component — first install needs one restart.
ha core restart
until ha core info >/dev/null 2>&1; do sleep 5; done
```

Then check that the add-on pushed a Supervisor discovery message
for the `socialhome` integration:

```sh
ha discovery
ha discovery | grep -A2 -B1 socialhome
```

A discovery row with `addon: local_socialhome` and `service:
socialhome` (or whatever domain the integration declares) means
the discovery push from `HaBootstrap` reached the Supervisor.

Tail HA Core logs while the discovery flow runs — Home Assistant
logs the discovery received, the config flow it spawns, and any
import errors from the freshly-installed custom_component:

```sh
ha core logs --follow 2>&1 | grep -E 'socialhome|discovery|config_flow|custom_components'
```

What you want to see:

- `Setting up socialhome` or `socialhome: Loaded` — manifest parsed
  and the integration imported cleanly.
- `Found new service: socialhome` or `Discovered socialhome via
  hassio` — the addon's Supervisor discovery push landed.
- `Created config entry for socialhome` (after approval, see
  step 8) — config flow committed.

Red flags:

- `Integration 'socialhome' not found` — `install-integration`
  failed (network down, zip layout wrong); inspect
  `ha addons logs local_socialhome` for the warning line.
- `Error setting up entry socialhome` — runtime/import failure in
  the integration; the traceback in HA core logs points at the
  offending file under `/config/custom_components/socialhome/`.
- `Invalid manifest` — the release zip layout doesn't match what
  `install-integration.sh` expects; revisit the archive-shape
  branch in the script.

### 7a — Backup hooks (`backup_pre` / `backup_post`)

The add-on declares `backup: hot` plus a `backup_pre` /
`backup_post` pair pointing at scripts shipped in `rootfs/etc/
socialhome/`. The pre-hook POSTs to the SH server's
`POST /api/backup/pre_backup`, which runs
`PRAGMA wal_checkpoint(TRUNCATE)` so freshly-committed pages in
`socialhome.db-wal` are folded into `socialhome.db` before the
Supervisor copies `/data`. Without it the snapshot is internally
consistent but can miss the most recent writes; with it the add-on
stays online and the operator sees zero downtime.

Verify the supervisor actually exec's the hooks during a snapshot
(it doesn't log them at `info` — bump to `debug` for the duration
of the test):

```sh
# 1) Optional: raise supervisor logging so the exec is visible.
HA_TOKEN=$(docker inspect homeassistant --format \
    '{{range .Config.Env}}{{println .}}{{end}}' \
    | grep SUPERVISOR_TOKEN | cut -d= -f2)
docker exec homeassistant curl -sS \
    -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
    -H 'Content-Type: application/json' \
    http://supervisor/supervisor/options -d '{"logging":"debug"}'

# 2) Trigger a partial backup that only captures this addon.
ha backups new --app local_socialhome --name "skill-backup-test" --no-progress

# 3) Confirm both hooks fired. The pre-hook should run before any
#    addon image export; the post-hook after.
docker logs hassio_supervisor 2>&1 \
    | grep -aiE "Exec command '/etc/socialhome/" | tail
# expected (one of each):
# Exec command '/etc/socialhome/backup-pre.sh'  in addon_local_socialhome exited with 0
# Exec command '/etc/socialhome/backup-post.sh' in addon_local_socialhome exited with 0
```

A non-zero exit from either script is supervisor-level FATAL —
the backup aborts and the addon's hook gets blamed. The scripts
the repo ships always exit 0 (a missing integration token or a
SH-side 5xx is logged as a warning, never propagated), so a
non-zero exit means the script itself is broken — re-read it.

Smoke-test the pre-hook directly inside the addon container
without running a full backup:

```sh
docker exec addon_local_socialhome /etc/socialhome/backup-pre.sh
# expected: backup-pre: {"ok": true, "busy": 0, "log_frames": …, "checkpointed_frames": …}
```

Don't forget to drop supervisor logging back to `info` after the
test:

```sh
docker exec homeassistant curl -sS \
    -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
    -H 'Content-Type: application/json' \
    http://supervisor/supervisor/options -d '{"logging":"info"}'
```

Red flags:

- `Exec command '…/backup-pre.sh' … exited with <non-zero>` — the
  script crashed (curl couldn't reach `127.0.0.1:8099`, jq parse,
  …). Backup aborts. Investigate the script's output (the
  supervisor logs the captured stdout/stderr at debug on failure).
- No `Exec command` line at all but the addon is `hot` and
  `backup_pre`/`backup_post` are in `config.yaml` — config wasn't
  reloaded after the edit. Uninstall + reinstall the addon so
  Supervisor re-reads `config.yaml`.

### 7b — Federation inbound + base-URL forwarding

Social Home federates over the public internet, so the
integration has to push two things into the add-on that you can't
verify from inside the supervisor sandbox alone:

* **Base URL forward** — HA's `external_url` (or Nabu Casa Remote
  UI) is the address peers see. The integration forwards it to the
  Social Home server so the SH instance knows its own public
  origin. Without it the SH server emits federation envelopes that
  point at `homeassistant.local` and peers drop them.
* **Federation inbound forward** — federation peers POST to a
  publicly-reachable URL under HA (e.g.
  `https://<external>/api/socialhome/inbox`) and HA proxies the
  body through to the add-on's `/federation/inbox` (or whichever
  endpoint the integration registers). The proxy mirrors how
  `notify` / `webhook` integrations expose add-on endpoints to the
  outside world.

Verify both before the visual handoff:

```sh
# 1) Confirm external_url is set on the HA side — the integration
#    only pushes a base URL when HA has one to push.
ACCESS_TOKEN=$(jq -r .access_token /tmp/tok.json)
docker exec hassio_supervisor curl -sS \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  http://homeassistant:8123/api/config | jq '{external_url, internal_url}'

# 2) Inspect the SH server's resolved base URL. The HaBootstrap /
#    HA adapter writes it under [homeassistant] in the live config,
#    surfaced via /api/instance.
docker exec hassio_supervisor curl -sS \
  http://addon_local_socialhome:8099/api/instance | jq '{base_url, federation_inbox_url}'

# 3) Hit the federation inbox through the HA proxy from outside
#    the supervisor network — proves the inbound path is wired.
#    Replace <external> with the host:7123 forwarding the
#    devcontainer publishes (or the Nabu Casa URL on a real HAOS
#    install). A POST with a stub envelope should land in the SH
#    server's federation log within a second.
curl -fsS -X POST \
  -H 'Content-Type: application/activity+json' \
  -d '{"type":"Probe","from":"addon-testing-skill","at":"'$(date -u +%FT%TZ)'"}' \
  http://localhost:7123/api/socialhome/inbox
docker exec addon_local_socialhome \
  grep -aE 'federation.*(inbox|Probe)' /proc/1/fd/1 | tail -5
```

What you want to see:

- `external_url` non-null in `/api/config` (set it in
  *Settings → System → Network → Home Assistant URL* if missing).
- `base_url` in `/api/instance` matches that external URL — not
  `http://homeassistant.local:8099`.
- The probe POST returns 2xx and the add-on logs an `inbox`
  receive line for the probe envelope.

Red flags:

- `base_url` still points at the supervisor hostname — the
  integration's `_push_external_url` hook didn't fire; check the
  coordinator's startup logs and the `external_url` setting on HA.
- The probe POST returns `404` on HA — the integration didn't
  register the `/api/socialhome/inbox` view (or the route name
  changed); cross-check the integration's `http.py` /
  `async_setup` against the add-on's federation router.
- The POST returns 2xx but nothing reaches the add-on — the proxy
  is registered but its `async_handle_post` is dropping the body;
  enable `homeassistant.components.socialhome` debug logging via
  step 7's `logger/set_level` call.

### 8 — Hand off for external visual verification

Stop here and ask the user to open the UI themselves. The
devcontainer forwards Home Assistant on port **7123** of the host
(`.devcontainer/devcontainer.json` → `appPort`). From the user's
own machine:

```
http://<host-or-codespace>:7123/
```

After login, the Social Home panel appears in the sidebar (icon
`mdi:home-account`, title from `panel_title`). Ask the user to:

1. Open the **Social Home** panel — confirm the SPA loads through
   ingress without a mixed-content / CORS error.
2. Check **Settings → Add-ons → Social Home → Log** in the HA UI
   for the same log stream you tailed in step 5.
3. Open **Settings → Devices & services** and find the *Social
   Home* card under **Discovered**. Click **Configure** /
   **Approve** to accept the discovery from the add-on. The
   config flow should complete without prompting for credentials
   — the integration token already lives in `/data/integration_
   token.txt` (minted by `HaBootstrap`) and the discovery payload
   carries it across.
4. After approval, confirm the integration appears under
   **Configured** with a single entry whose source reads
   *Discovered via Home Assistant Supervisor*.
5. Cross-check **Settings → System → Logs** (or
   `ha core logs --follow` from step 7) for any
   `socialhome`-tagged warnings/errors the user sees in the UI.
6. Report back what they see — surface any console errors or
   missing assets so the next iteration can address them.

Do **not** click through the UI on the user's behalf; the goal of
this step is for the user to confirm the experience matches what
they expect on their own network.
