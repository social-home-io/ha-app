#!/command/with-contenv bashio
# ==============================================================================
# init-config — render /data/socialhome.toml from add-on options.
#
# Runs as a oneshot before the ``socialhome`` longrun starts (s6-rc
# resolves the dependency via ``socialhome/dependencies.d/init-config``).
# The longrun's ``run`` script then ``exec``s the Python server
# against the file produced here.
# ==============================================================================

bashio::log.info "Rendering /data/socialhome.toml..."

mkdir -p /data

# Drop the pre-rename TOML if an operator upgraded through it.
# ``socialhome.toml`` is the source of truth from now on; the old
# file is dead weight (the run script reads
# ``SH_CONFIG=/data/socialhome.toml``).
rm -f /data/social_home.toml

# Stream the user options as a JSON document into ``tempio``, which
# renders the Go-template ``socialhome.toml.gtpl`` into
# ``/data/socialhome.toml``.
bashio::var.json \
    log_level         "$(bashio::config 'log_level')" \
    ai_task_entity_id "$(bashio::config 'ai_task_entity_id')" \
    stt_entity_id     "$(bashio::config 'stt_entity_id')" \
  | tempio \
      -template /etc/socialhome.toml.gtpl \
      -out /data/socialhome.toml

bashio::log.info "Configuration written to /data/socialhome.toml"
