#!/command/with-contenv bashio
# ==============================================================================
# init-config — render /data/social_home.toml from add-on options.
#
# Runs as a oneshot before the ``socialhome`` longrun starts (s6-rc
# resolves the dependency via ``socialhome/dependencies.d/init-config``).
# The longrun's ``run`` script then ``exec``s the Python server
# against the file produced here.
# ==============================================================================

bashio::log.info "Rendering /data/social_home.toml..."

mkdir -p /data

# Stream the user options as a JSON document into ``tempio``, which
# renders the Go-template ``social_home.toml.gtpl`` into
# ``/data/social_home.toml``.
bashio::var.json \
    log_level         "$(bashio::config 'log_level')" \
    ai_task_entity_id "$(bashio::config 'ai_task_entity_id')" \
    stt_entity_id     "$(bashio::config 'stt_entity_id')" \
  | tempio \
      -template /etc/social_home.toml.gtpl \
      -out /data/social_home.toml

bashio::log.info "Configuration written to /data/social_home.toml"
