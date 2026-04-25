# Social Home (Dev)

⚠️ **For testing.** This add-on rebuilds from the `main` branch
of [`social-home-io/socialhome`](https://github.com/social-home-io/socialhome)
on every push. Database schema, federation envelope formats, and
on-disk storage layouts can change between commits. Only run this
on an HA instance you don't mind wiping.

The behaviour is otherwise identical to the stable Social Home
add-on — same options, same storage layout, same integration
auto-discovery. See the [stable add-on
docs](../social_home/DOCS.md) for the option reference and
troubleshooting tips.

## Differences from stable

| Aspect | Stable | Dev |
|---|---|---|
| Image tag | `:<release>` (CalVer) | `:main` (rebuilt on every push) |
| Slug | `social_home` | `social_home_dev` |
| `/data` mount | `/addon_data/social_home` | `/addon_data/social_home_dev` |
| Default `log_level` | `info` | `debug` |

The two add-ons can run side by side — they get separate
persistent volumes and slugs, but they share the same Ingress
port (8099) and GFS port (8124), so the Supervisor only lets one
of them be **started** at a time.

## Reporting issues

File issues against [`social-home-io/socialhome`](https://github.com/social-home-io/socialhome/issues),
not this repo — the dev add-on is just packaging.
