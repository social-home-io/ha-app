#!/command/with-contenv bashio
# ==============================================================================
# init-config — render /data/socialhome.toml from add-on options.
#
# Runs as a oneshot before the ``socialhome`` longrun starts (s6-rc
# resolves the dependency via ``socialhome/dependencies.d/init-config``).
# ==============================================================================

bashio::log.info "Rendering /data/socialhome.toml..."

mkdir -p /data

# Drop the pre-rename TOML if an operator upgraded through it.
rm -f /data/social_home.toml

bashio::var.json \
    log_level         "$(bashio::config 'log_level')" \
    ai_task_entity_id "$(bashio::config 'ai_task_entity_id')" \
    stt_entity_id     "$(bashio::config 'stt_entity_id')" \
  | tempio \
      -template /etc/socialhome.toml.gtpl \
      -out /data/socialhome.toml

bashio::log.info "Configuration written to /data/socialhome.toml"
