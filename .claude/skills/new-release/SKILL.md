---
name: new-release
description: Cut a new CalVer release of the socialhome / socialhome_early add-ons. Branches off `main`, bumps the add-on CalVer and the pinned `SOCIALHOME_VERSION` / `CUSTOM_COMPONENT_VERSION` to whatever is latest upstream, drafts changelog entries on both add-ons, hands off to the user for any extra edits, opens a PR against `main`, then runs the `addon-testing` skill end-to-end against the build. Stops after testing — tagging is the maintainer's call.
---

# new-release

End-to-end release workflow for this repo. Pairs with
`addon-testing` — `new-release` prepares the branch and the diff,
opens the PR so CI can run in parallel, then invokes
`addon-testing` to validate the build runs cleanly inside the
devcontainer Supervisor.

## When to use

When you want to ship a new stable CalVer (e.g. `2026.M.D`) of
`socialhome` and `socialhome_early`. Both add-ons release
together — they share the Dockerfile, `run.sh`, and TOML
template, and only differ in slug + name + image tag. The same
CalVer goes on both `config.yaml` files.

## Prerequisites

- Working tree clean. The skill branches off `origin/main`
  regardless of where you currently are.
- `gh` authenticated for `social-home-io`.
- `jq` available.
- Inside the `ghcr.io/home-assistant/devcontainer:5-apps`
  devcontainer (the `addon-testing` step needs `supervisor_run`).

## Steps

### 1 — Pick the CalVer and cut the branch

Default is today's date in CalVer (`<year>.<month>.<day>`, no `v`
prefix, no leading zeros on month/day — see `CLAUDE.md` hard
rules).

```sh
CALVER=$(date +%Y.%-m.%-d)
git fetch origin main
git checkout -b release/${CALVER} origin/main
```

If `release/${CALVER}` already exists locally, decide before
clobbering:

- *resuming a release-in-progress* — `git switch` to it and skip
  to step 2 (or wherever the previous attempt left off);
- *same-day re-cut* — bump the day by 1 or add a suffix and
  confirm with the user before continuing.

### 2 — Bump the add-on CalVer on both add-ons

Both `config.yaml` files get the same `version:`. Always edit
both — they release together.

```sh
sed -i "s/^version: \".*\"/version: \"${CALVER}\"/" \
  socialhome/config.yaml socialhome_early/config.yaml
```

### 3 — Bump pinned upstream versions (if newer)

Each `build.yaml` pins two upstream releases:

- `SOCIALHOME_VERSION` — the Python server package
  (`social-home-io/socialhome`).
- `CUSTOM_COMPONENT_VERSION` — the HA integration zip
  (`social-home-io/ha-integration`).

Resolve the latest CalVer release on each repo and bump only if
newer than the current pin. A pure add-on-packaging release can
ship without either bump.

```sh
LATEST_SH=$(gh release list --repo social-home-io/socialhome \
              --limit 1 --json tagName --jq '.[0].tagName')
LATEST_INT=$(gh release list --repo social-home-io/ha-integration \
              --limit 1 --json tagName --jq '.[0].tagName')

CUR_SH=$(grep -oP '(?<=SOCIALHOME_VERSION: ")[^"]+' socialhome/build.yaml)
CUR_INT=$(grep -oP '(?<=CUSTOM_COMPONENT_VERSION: ")[^"]+' socialhome/build.yaml)

printf 'socialhome      : pinned %s  latest %s\n' "$CUR_SH"  "$LATEST_SH"
printf 'ha-integration  : pinned %s  latest %s\n' "$CUR_INT" "$LATEST_INT"
```

If `${LATEST_SH} != ${CUR_SH}`:

```sh
sed -i "s/^  SOCIALHOME_VERSION: \".*\"/  SOCIALHOME_VERSION: \"${LATEST_SH}\"/" \
  socialhome/build.yaml socialhome_early/build.yaml
```

If `${LATEST_INT} != ${CUR_INT}`:

```sh
sed -i "s/^  CUSTOM_COMPONENT_VERSION: \".*\"/  CUSTOM_COMPONENT_VERSION: \"${LATEST_INT}\"/" \
  socialhome/build.yaml socialhome_early/build.yaml
```

### 4 — Draft the changelog entries

Insert a short prose entry on top of each `CHANGELOG.md`. Same
format on both add-ons — terse paragraph, no bullet lists.

- Stable (`socialhome/CHANGELOG.md`): single paragraph stating
  the version-pin moves + one short line on the user-visible
  highlight from the upstream release notes.
- Early (`socialhome_early/CHANGELOG.md`): one paragraph noting
  it mirrors the stable add-on and restating the version-pin
  moves; refer to the stable changelog for the feature summary.

Skeleton — stable:

```markdown
## <CalVer>

Bumps the bundled Social Home server from `<OLD_SH>` to `<NEW_SH>`;
HA integration <stays at `<CUR_INT>` | bumps to `<NEW_INT>`>.
<one short line summarising the user-visible change>.
```

Skeleton — early:

```markdown
## <CalVer>

Mirrors stable `socialhome` <CalVer> — see its changelog for the
feature summary. Bumps the bundled Social Home server from
`<OLD_SH>` to `<NEW_SH>`; HA integration <stays at `<CUR_INT>` |
bumps to `<NEW_INT>`>.
```

Pull the highlight line from the upstream release notes:

```sh
gh release view ${LATEST_SH} --repo social-home-io/socialhome
```

If neither pinned version changed and this is a pure-packaging
release, write a one-line entry describing what the add-on itself
changed (e.g. *"Adds non-admin panel visibility"*).

### 5 — Hand off to the user

Stop and ask the user:

- whether the auto-detected upstream bumps are correct
  (sometimes you want to pin behind latest deliberately);
- whether they want to make other config/docs edits on the
  branch (panel toggles, new `options:` entries, README copy,
  DOCS, etc.).

Wait for explicit confirmation before continuing. The user
typically will say *"keep going"* / *"looks good"* — anything
short of that means pause and apply their edits first.

### 6 — Commit

One commit, both add-ons, release-shaped subject (match the
`git log` style on `main`). The working tree must be clean of
`addon-testing` artefacts at this point — testing hasn't run
yet, so there should be no `socialhome/config.yaml.bak` and no
stripped `image:` line. Confirm:

```sh
grep -n '^image:' socialhome/config.yaml   # must print the image: line
ls socialhome/config.yaml.bak 2>/dev/null  # must print nothing
```

Then commit:

```sh
git add -- \
  socialhome/config.yaml      socialhome/build.yaml      socialhome/CHANGELOG.md \
  socialhome_early/config.yaml socialhome_early/build.yaml socialhome_early/CHANGELOG.md

git commit -m "$(cat <<EOF
release(${CALVER}): socialhome / socialhome_early add-ons

Bumps both add-ons to ${CALVER}. Pins SOCIALHOME_VERSION to
${LATEST_SH}; CUSTOM_COMPONENT_VERSION <stays at ${CUR_INT} | moves
to ${LATEST_INT}>.

<one-liner per non-version-bump change, if any>
EOF
)"
```

Stage only the files listed above — `git add -A` will silently
include unrelated leftovers.

### 7 — Push and open the PR

The PR opens *before* `addon-testing` runs so the HA add-on
validator (CI) can soak in parallel with the local build. The
test-plan checkboxes are left **unchecked** on creation —
`addon-testing` checks them after the user gives *"looks good"*
in step 8.

```sh
git push -u origin release/${CALVER}

gh pr create --base main --head release/${CALVER} \
  --title "release(${CALVER}): socialhome / socialhome_early add-ons" \
  --body "$(cat <<EOF
## Summary
- Bumps both add-ons to \`${CALVER}\`.
- \`SOCIALHOME_VERSION\` → \`${LATEST_SH}\`.
- \`CUSTOM_COMPONENT_VERSION\` <stays at \`${CUR_INT}\` | → \`${LATEST_INT}\`>.
- <other release-branch changes, if any>

## Test plan
- [ ] \`/addon-testing\` — local build, install/update, healthy startup logs, \`/healthz\` ok, discovery push observed.
- [ ] Visual verification at \`http://<host>:7123/\` — SocialHome panel loads through ingress; Devices & services → discovery approves cleanly.
EOF
)"
```

Capture and hold on to the PR URL — you'll surface it to the
user at the end of step 8 and use it to flip the test-plan
checkboxes once testing is green.

### 8 — Run `addon-testing`

Invoke the `addon-testing` skill end to end. It builds the
add-on locally inside the devcontainer Supervisor, installs /
updates / restarts it, tails the logs, and walks the operator
through visual verification at `http://<host>:7123/`.

The testing skill modifies `socialhome/config.yaml` mid-run
(strips the `image:` line to force a local build) and is itself
responsible for restoring the line in its step 9. Those mid-run
edits sit **on top of** the already-pushed release commit; they
should never reach `git commit`. When the skill returns,
sanity-check the working tree is clean:

```sh
grep -n '^image:' socialhome/config.yaml
git status --short
```

`git status --short` should be empty — the release commit is
already pushed, and `addon-testing`'s cleanup undid everything
it touched. Any lingering modification means the testing skill's
cleanup didn't fully run; restore from `git checkout` before
moving on.

The visual-verification handoff at the end of `addon-testing`
must complete with a user *"looks good"*. Once it does, flip the
test-plan checkboxes on the open PR:

```sh
gh pr edit <pr-number> --body "$(gh pr view <pr-number> --json body --jq .body | sed 's/- \[ \]/- [x]/g')"
```

If the test surfaces a regression, fix it on the same branch and
push a follow-up commit — the PR is already open and will pick
up the new commit automatically. Re-run `addon-testing` until
green, then flip the checkboxes.

Return the PR URL to the user.

## Notes

- **Two add-ons, one source of truth.** Every edit to a shared
  file in `socialhome/` mirrors into `socialhome_early/` — only
  `config.yaml` differs (version, slug, image tag). See
  `CLAUDE.md` hard rules.
- The PR is opened **before** `addon-testing` so the HA add-on
  validator runs in parallel with the local build. Failures are
  fixed with follow-up commits on the same branch; the test-plan
  checkboxes only flip to `[x]` once testing is green.
- The git **tag** that triggers the release-image build is cut
  separately by the maintainer after this PR merges. This skill
  stops once `addon-testing` returns green.
