#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# backup-pre — checkpoint the SQLite WAL before Supervisor snapshots /data.
#
# Without this hook the Supervisor copies ``/data`` while
# ``socialhome.db-wal`` may still hold freshly-committed pages that
# haven't been folded into ``socialhome.db``. The resulting archive
# is internally consistent (sqlite WAL recovery handles it on
# restore) but loses every write between the previous checkpoint
# and the snapshot moment.
#
# ``POST /api/backup/pre_backup`` runs ``PRAGMA wal_checkpoint(TRUNCATE)``
# server-side so the snapshot picks up every durable byte. Falls
# back to a no-op + warning on any failure — a missed checkpoint
# means a slightly-stale backup, never a corrupted one, so a
# blocked backup is the worse outcome.
# ==============================================================================

set -u

TOKEN_FILE="/data/integration_token.txt"
ENDPOINT="http://127.0.0.1:8099/api/backup/pre_backup"

if ! [ -s "${TOKEN_FILE}" ]; then
    bashio::log.warning "backup-pre: no integration token at ${TOKEN_FILE} — skipping WAL checkpoint"
    exit 0
fi

response="$(curl -fsS --max-time 10 -X POST \
    -H "Authorization: Bearer $(cat "${TOKEN_FILE}")" \
    "${ENDPOINT}" 2>&1)" || {
    bashio::log.warning "backup-pre: WAL checkpoint failed: ${response}"
    exit 0
}

bashio::log.info "backup-pre: ${response}"
