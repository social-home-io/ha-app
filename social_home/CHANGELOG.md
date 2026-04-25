# Changelog

## 2026.4.25

- Initial public release.
- Auto-provisions the HA owner as Social Home admin.
- Mints an integration token and pushes a Supervisor discovery
  record so [`ha-integration`](https://github.com/social-home-io/ha-integration)
  auto-configures itself on first boot.
- Renders `social_home.toml` from the user options via `bashio`
  + `tempio` on every start.
