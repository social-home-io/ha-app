# Changelog

## 2026.5.10

- Initial public release.
- Installs `socialhome==2026.5.10` from PyPI on top of the
  official HA Python base image (Alpine + s6-overlay v3).
- Auto-provisions the HA owner as the Social Home admin.
- Mints an integration token and pushes a Supervisor discovery
  record so [`ha-integration`](https://github.com/social-home-io/ha-integration)
  auto-configures itself on first boot.
- s6-rc renders `/data/social_home.toml` via the `init-config`
  oneshot before the `socialhome` longrun starts.
- Supports `aarch64` + `amd64`.
