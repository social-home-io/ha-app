#!/usr/bin/with-contenv bashio
# ==============================================================================
# run.sh — Social Home HA add-on entry point.
#
# All bootstrap logic (HA owner provisioning, integration token,
# Supervisor discovery push) is handled by the Python core's
# ``HaBootstrap`` on first start. This script's only job is to
# render ``/data/social_home.toml`` from the user options and
# ``exec`` the server.
# ==============================================================================

bashio::log.info "Starting Social Home..."

mkdir -p /data

# Stream the user options as a JSON document into ``tempio``,
# which renders the Go-template ``social_home.toml.gtpl`` into
# ``/data/social_home.toml``. The leading ``^`` on ``gfs_enable``
# tells ``bashio::var.json`` to emit a raw boolean instead of
# quoting it as a string — TOML keeps booleans unquoted.
bashio::var.json \
    log_level                "$(bashio::config 'log_level')" \
    turn_url                 "$(bashio::config 'turn_url')" \
    turn_secret              "$(bashio::config 'turn_secret')" \
    ai_calendar_import_agent "$(bashio::config 'ai_calendar_import_agent')" \
    gfs_enable               "^$(bashio::config 'gfs_enable')" \
    gfs_base_url             "$(bashio::config 'gfs_base_url')" \
  | tempio \
      -template /etc/social_home.toml.gtpl \
      -out /data/social_home.toml

bashio::log.info "Configuration written to /data/social_home.toml"

# SUPERVISOR_TOKEN / SUPERVISOR_URL are injected by the HA
# Supervisor; the Python core picks them up from the environment.
exec python -m social_home.app --config /data/social_home.toml
