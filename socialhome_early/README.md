# Social Home (Early)

**The social home for your household — early-access channel.**

The same household OS and federated social network as the stable
[`socialhome`](../socialhome/README.md) add-on — calendar,
shopping list, photos, chat, highlights, moments, all running on
your own Home Assistant — packaged from the same source. The
early-access channel just leads stable by one rollout: a release
candidate lands here first so it can soak with a small audience
before it's promoted.

> ⚠️ **Pre-promotion builds.** This channel ships release
> candidates ahead of stable. Behaviour should match the upcoming
> stable release, but the point of the channel is to catch the
> bugs that didn't, so keep that in mind on production data.

## When to use this

- You want to help shake out a release candidate before it ships
  to the stable channel.
- You're tracking a fix that landed on `social-home-io/socialhome`
  this week and don't want to wait for the next stable cut.

For everyday household use, install
[`socialhome`](../socialhome/README.md) instead.

## Install

In the Supervisor: **Add-on Store → ⋮ → Repositories** and add
`https://github.com/social-home-io/ha-app`. The early-access
add-on then shows up under *Add-on Store → Social Home (Early)*.
Same auto-discovery flow as stable — refresh **Settings → Devices
& services** after install and click **Configure** on the
discovery card.

See [`DOCS.md`](DOCS.md) for the in-app option reference,
[`CHANGELOG.md`](CHANGELOG.md) for what's new, and report bugs
against [`social-home-io/socialhome`](https://github.com/social-home-io/socialhome/issues)
— this repo is just the packaging.
