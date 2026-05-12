#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# backup-post — symmetric acknowledgement after the Supervisor
# finishes snapshotting ``/data``.
#
# ``POST /api/backup/post_backup`` is a no-op on the server today,
# reserved for future quiesce/resume logic (releasing any write
# pause the pre-hook might introduce later). Calling it now means
# the hook stays in place when the server grows that logic; the
# add-on doesn't have to ship a follow-up release.
# ==============================================================================

set -u

TOKEN_FILE="/data/integration_token.txt"
ENDPOINT="http://127.0.0.1:8099/api/backup/post_backup"

if ! [ -s "${TOKEN_FILE}" ]; then
    exit 0
fi

curl -fsS --max-time 10 -X POST \
    -H "Authorization: Bearer $(cat "${TOKEN_FILE}")" \
    "${ENDPOINT}" >/dev/null 2>&1 || true
