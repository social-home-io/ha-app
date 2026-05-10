#!/command/with-contenv bashio
# ==============================================================================
# init-config — render /data/social_home.toml from add-on options.
#
# Runs as a oneshot before the ``socialhome`` longrun starts (s6-rc
# resolves the dependency via ``socialhome/dependencies.d/init-config``).
# ==============================================================================

bashio::log.info "Rendering /data/social_home.toml..."

mkdir -p /data

bashio::var.json \
    log_level         "$(bashio::config 'log_level')" \
    ai_task_entity_id "$(bashio::config 'ai_task_entity_id')" \
    stt_entity_id     "$(bashio::config 'stt_entity_id')" \
  | tempio \
      -template /etc/social_home.toml.gtpl \
      -out /data/social_home.toml

bashio::log.info "Configuration written to /data/social_home.toml"
