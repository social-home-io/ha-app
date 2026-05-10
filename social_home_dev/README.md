# Social Home (Dev)

**The social home for your household — pre-release channel.**

The same household OS and federated social network as the stable
[`social_home`](../social_home/README.md) add-on — calendar,
shopping list, photos, chat, highlights, moments, all running on
your own Home Assistant — but tracking CalVer pre-releases of
`socialhome` so you can try changes before they're promoted to
stable.

> ⚠️ **For testing only.** Database schema and federation
> envelope formats can shift between pre-releases. Only run this
> on a Home Assistant instance you don't mind wiping.

## When to use this

- You want to validate a fix or feature on real data before it
  ships to the stable channel.
- You're contributing to
  [`social-home-io/socialhome`](https://github.com/social-home-io/socialhome)
  and need an add-on packaging the pre-release wheel.

For everyday household use, install
[`social_home`](../social_home/README.md) instead.

## Install

In the Supervisor: **Add-on Store → ⋮ → Repositories** and add
`https://github.com/social-home-io/ha-app`. The dev add-on then
shows up under *Add-on Store → Social Home (Dev)*. Same
auto-discovery flow as stable — refresh **Settings → Devices &
services** after install and click **Configure** on the discovery
card.

See [`DOCS.md`](DOCS.md) for the in-app option reference,
[`CHANGELOG.md`](CHANGELOG.md) for what's new, and report bugs
against [`social-home-io/socialhome`](https://github.com/social-home-io/socialhome/issues)
— this repo is just the packaging.
