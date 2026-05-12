#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# install-integration — sync the pinned ``socialhome`` custom_component
# into ``/homeassistant/custom_components/`` from the zip baked into
# the image at build time.
#
# The add-on ships a tested pair of versions:
#
#   * the ``socialhome`` Python core (``SOCIALHOME_VERSION``);
#   * the matching ``ha-integration`` release pinned via
#     ``CUSTOM_COMPONENT_VERSION`` — the zip is fetched at
#     image-build time and stored at ``/opt/socialhome/custom_component.zip``.
#
# At every boot we read the bundled zip's own
# ``manifest.json::version`` and compare it against the manifest
# already on disk. Match → no-op. Mismatch (older, newer, missing)
# → unzip the baked archive into place. The bundled zip is the
# single source of truth for the target version; there is no
# separate runtime env to keep in sync, and no network fetch on
# the boot path — HAOS comes up clean even when offline.
# ==============================================================================

set -u

DOMAIN="socialhome"
DEST="/homeassistant/custom_components/${DOMAIN}"
MANIFEST="${DEST}/manifest.json"
ZIP_PATH="/opt/socialhome/custom_component.zip"

if ! [ -d /homeassistant ]; then
    bashio::log.warning "install-integration: /homeassistant not mounted — skipping"
    exit 0
fi

if ! [ -f "${ZIP_PATH}" ]; then
    bashio::log.warning "install-integration: ${ZIP_PATH} missing — image build skipped the fetch"
    exit 0
fi

target_version="$(unzip -p "${ZIP_PATH}" manifest.json 2>/dev/null \
    | jq -r '.version // ""' 2>/dev/null || true)"
if [ -z "${target_version}" ]; then
    bashio::log.warning "install-integration: ${ZIP_PATH} has no readable manifest — skipping"
    exit 0
fi

bashio::log.info "install-integration: bundled ${DOMAIN} ${target_version}"

installed_version=""
if [ -f "${MANIFEST}" ]; then
    installed_version="$(jq -r '.version // ""' "${MANIFEST}" 2>/dev/null || true)"
fi

if [ "${installed_version}" = "${target_version}" ]; then
    bashio::log.info "install-integration: ${DOMAIN} ${installed_version} already current"
    exit 0
fi

bashio::log.info \
    "install-integration: syncing ${DOMAIN} ${installed_version:-<none>} → ${target_version}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

if ! unzip -q "${ZIP_PATH}" -d "${tmpdir}/unpacked"; then
    bashio::log.warning "install-integration: ${ZIP_PATH} corrupt — keeping ${installed_version:-none}"
    exit 0
fi

# Locate the integration folder inside the archive. The HACS release
# asset is flat (``manifest.json`` at root). The two fallback shapes
# (``${DOMAIN}/manifest.json`` under root; a nested ``manifest.json``
# anywhere) survive a release-format change without a rebuild.
src=""
if [ -f "${tmpdir}/unpacked/manifest.json" ]; then
    src="${tmpdir}/unpacked"
elif [ -f "${tmpdir}/unpacked/${DOMAIN}/manifest.json" ]; then
    src="${tmpdir}/unpacked/${DOMAIN}"
else
    nested="$(find "${tmpdir}/unpacked" -maxdepth 4 -type f -name manifest.json \
        -print 2>/dev/null | head -n 1)"
    [ -n "${nested}" ] && src="$(dirname "${nested}")"
fi

if [ -z "${src}" ] || [ ! -d "${src}" ]; then
    bashio::log.warning "install-integration: manifest.json not found in ${ZIP_PATH}"
    exit 0
fi

mkdir -p "$(dirname "${DEST}")"
rm -rf "${DEST}.new"
cp -a "${src}" "${DEST}.new"
rm -rf "${DEST}"
mv "${DEST}.new" "${DEST}"

bashio::log.info "install-integration: ${DOMAIN} ${target_version} installed at ${DEST}"
