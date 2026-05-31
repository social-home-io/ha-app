# Changelog

## 2026.5.31

Bumps the bundled Social Home server from `2026.5.24.3` to
[`2026.5.31`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.31);
HA integration stays at `2026.5.23`. Adds a soft, reversible
space Archive (federated read-only) and shifts DM/space media
over a dedicated binary DataChannel for faster transfers.

## 2026.5.24.3

Bumps the bundled Social Home server from `2026.5.24.2` to
[`2026.5.24.3`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.24.3);
HA integration stays at `2026.5.23`. Admin-initiated "add
member" now requires the invitee's consent (no silent adds), and
the space member list falls back to the household avatar when a
per-user avatar isn't set.

## 2026.5.24.2

Bumps the bundled Social Home server from `2026.5.24.1` to
[`2026.5.24.2`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.24.2);
HA integration stays at `2026.5.23`. Sync state machine now
emits `DIRECT_READY` / `DIRECT_FAILED` events and falls back to
HTTPS chunks when the direct transport is unavailable.

## 2026.5.24.1

Bumps the bundled Social Home server from `2026.5.24` to
[`2026.5.24.1`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.24.1);
HA integration stays at `2026.5.23`. Renders cross-household
avatars on the space map and fixes photo upload on the HA
Android app.

## 2026.5.24

Bumps the bundled Social Home server from `2026.5.23.2` to
[`2026.5.24`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.24);
HA integration stays at `2026.5.23`. Fills in missing post
`DELETE` / `PATCH` and comments `GET` routes, federates space
config changes in realtime, stops event-derived posts firing
twice, and surfaces cross-household nicknames + pictures in the
member list.

## 2026.5.23.2

Bumps the bundled Social Home server from `2026.5.23.1` to
[`2026.5.23.2`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.23.2);
HA integration stays at `2026.5.23`. Extends cross-household
federation to virtually every space surface — pages, bazaar
listings and bids, stickies, tasks, zones, polls, schedules,
location updates, and member avatars; fixes a duplicate-comment
outbound bug.

## 2026.5.23.1

Bumps the bundled Social Home server from `2026.5.23` to
[`2026.5.23.1`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.23.1);
HA integration stays at `2026.5.23`. Federates picture / video /
gallery / listing bytes to remote members (not just metadata),
fixes HEIC uploads from the HA Android Companion, and shows
remote members on the space map; addon image adds `libheif` for
the HEIC decode path.

## 2026.5.23

Bumps the bundled Social Home server from `2026.5.22.2` to
[`2026.5.23`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.23);
HA integration moves from `2026.5.18` to
[`2026.5.23`](https://github.com/social-home-io/ha-integration/releases/tag/2026.5.23).
Cross-household spaces now work end-to-end — Safari Accept,
member roster, content key on accept, federated post lifecycle,
and member-kick epoch rotation; the integration drops the
redundant ICE-server push since the backend reads HA Core's
provider directly.

## 2026.5.22.1

Bumps the bundled Social Home server from `2026.5.22.1` to
[`2026.5.22.2`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.22.2);
HA integration stays at `2026.5.18`. Re-enables the composer
Post button after image upload, adds household members to the
space invite picker, and restores the mobile space-settings
icon; federation transport drain survives polite-rollback PC
swaps.

## 2026.5.22

Bumps the bundled Social Home server from `2026.5.21.2` to
[`2026.5.22.1`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.22.1);
HA integration stays at `2026.5.18`. Adds federation mesh
routing with E2E-encrypted `SPACE_ROUTED` envelopes and
cross-instance space-invite redemption; restores the highlights
public viewer; fixes the RTC perfect-negotiation IntEnum
mismatch that broke handshakes.

## 2026.5.21.2

Bumps the bundled Social Home server from `2026.5.21.1` to
[`2026.5.21.2`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.21.2);
HA integration stays at `2026.5.18`. Adds personal aliases for
friends, a header-button "Join with code" dialog, and a
mobile-friendly space tab strip overflow; polishes the Zones map
(z-index, legend, tap popup, ghost circles).

## 2026.5.21.1

Bumps the bundled Social Home server from `2026.5.21` to
[`2026.5.21.1`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.21.1);
HA integration stays at `2026.5.18`. Adds cross-household space
invites (peer-member picker, invite codes, ingress-aware links,
QR), per-space admin gates for pages / calendar / tasks /
stickies / gallery, a per-space share-my-location toggle, and
WebRTC perfect-negotiation glare resolution.

## 2026.5.21

Bumps the bundled Social Home server from `2026.5.20` to
[`2026.5.21`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.21);
HA integration stays at `2026.5.18`. Adds a desktop reaction
button on DMs and `@` store autocomplete in shopping; isolates
the LocationMap stacking context so the sidebar stays on top;
quiets false-positive DM gap warnings.

## 2026.5.20

Bumps the bundled Social Home server from `2026.5.19.1` to
[`2026.5.20`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.20);
HA integration stays at `2026.5.18`. Adds online/idle/offline
indicators for remote friends and unifies household + user
preferences in one table; fixes the FederationMap floating over
the sidebar plus several pairing / WebRTC reliability bugs.

## 2026.5.19

Bumps the bundled Social Home server from `2026.5.18.2` to
[`2026.5.19.1`](https://github.com/social-home-io/socialhome/releases/tag/2026.5.19.1);
HA integration stays at `2026.5.18`. Adds cross-household polish
— local aliases for paired peers, cross-house 1:1 DMs, transport
indicators (⚡ direct / ☁ fallback), a Connections → Map tab,
and a per-pair share-home toggle in the pairing wizard.

## 2026.5.18.3

Social Home server stays at `2026.5.18.2`; HA integration moves
from `2026.5.11.4` to
[`2026.5.18`](https://github.com/social-home-io/ha-integration/releases/tag/2026.5.18).
The integration's federation inbox proxy now forwards the
add-on's `Content-Type` via headers instead of `content_type=`,
so remote peers see the add-on's real status code and HAOS
federation no longer loops on 500s — completing the
HAOS↔HAOS pairing path started in `2026.5.18.2`.

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
