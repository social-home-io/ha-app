# Social Home

**The social home for your household.**

Calendar, shopping list, photos, chat, highlights, moments —
running on your own Home Assistant. A household OS that's also a
social network you actually own.

[Add to Home Assistant](https://my.home-assistant.io/redirect/supervisor_addon/?addon=752dab87_social_home&repository_url=https%3A%2F%2Fgithub.com%2Fsocial-home-io%2Fha-app)
· [social-home.io](https://social-home.io)
· [Docs](https://social-home.io/docs/)

## Why Social Home

- **Your server, your rules.** Everything lives on your Home
  Assistant. No third-party cloud touches your day.
- **End-to-end encrypted.** Sensitive spaces are sealed on your
  device — not even the relay can read them.
- **Federation, not silos.** Connect households one QR scan at a
  time. Pair, then talk directly.
- **Open source. No ads.** MPL 2.0. No analytics, no growth team
  trying to monetise your evening.

## What you get

Calendars, shopping lists, tasks, notes, pages, presence, voice —
every shared logistics surface a household actually needs — and
the warm parts of social media (feeds, photos, DMs, calls, group
rooms) without giving anyone something to sell.

## Install

Click **Add to Home Assistant** above, or in the Supervisor UI:
**Add-on Store → ⋮ → Repositories** and add
`https://github.com/social-home-io/ha-app`. The Social Home
add-on then shows up under *Add-on Store → Social Home*.

After install, refresh **Settings → Devices & services** and
click **Configure** on the auto-discovered Social Home card —
the matching [`ha-integration`](https://github.com/social-home-io/ha-integration)
configures itself from there.

See [`DOCS.md`](DOCS.md) for the in-app option reference and
[`CHANGELOG.md`](CHANGELOG.md) for release notes.

For the bleeding-edge channel that pulls socialhome pre-releases
ahead of stable, see [`social_home_dev`](../social_home_dev/README.md).
