# syntax=docker/dockerfile:1.7
#
# Social Home — Home Assistant add-on (stable channel).
#
# Built on the official HA Python base image (Alpine + s6-overlay
# v3 + bashio + tempio + ``/usr/local`` Python 3.14). The SPA bundle
# is baked into the upstream socialhome wheel so this image needs
# no node / pnpm.
#
# Two-stage build: the ``builder`` stage carries the C/C++ toolchain
# needed to compile native deps that don't publish musllinux wheels
# (notably ``aiolibdatachannel``, which vendors ``libdatachannel``
# and builds it via CMake). The final stage installs from the
# resulting wheelhouse with ``--no-index`` so no toolchain bytes
# survive into the runtime image.

ARG BUILD_FROM

# ---------- builder stage ----------------------------------------
FROM ${BUILD_FROM} AS builder

# hadolint ignore=DL3018
RUN apk add --no-cache \
        build-base \
        cmake \
        git \
        linux-headers \
        openssl-dev \
        pkgconf

# uv turns Social Home's ``uv.lock`` into the hashed requirements file
# below. Static musl binaries for amd64 + aarch64 from Astral's official
# image, pinned by tag AND by the multi-arch index digest, so a re-pushed
# tag can't swap the binary. Keep the version at (or above) the uv that
# Social Home pins (``Dockerfile.sh`` / CI ``setup-uv``): an older uv may
# not read a newer lock format.
COPY --from=ghcr.io/astral-sh/uv:0.12.10@sha256:2bb3ebca0a796a155094a27773d290c4b074572e6107f171d88d086682fd2500 \
    /uv /usr/local/bin/uv

ARG SOCIALHOME_VERSION
# Locked dependency set. Every Social Home release commits ``uv.lock``
# (with ``pyproject.toml``). Both are fetched for exactly
# ``SOCIALHOME_VERSION`` (by git tag, online build like the integration
# zip below) and ``uv export --frozen`` turns the lock into a
# requirements file — every runtime package, transitive ones included,
# at an exact version with the sha256 of each published file. The flags
# match Social Home's own ``scripts/lock.sh`` / ``Dockerfile.sh``
# export. ``--frozen`` reads the lock as-is (no resolve, no network);
# ``--no-emit-project`` leaves socialhome itself out. Then:
#   1. ``pip3 wheel --require-hashes -r`` builds the wheelhouse from
#      exactly that set — any file whose hash isn't listed is refused.
#      ``aiolibdatachannel`` has no musllinux wheel, so it compiles here
#      from its locked, hashed sdist.
#   2. socialhome itself joins with ``--no-deps``. (It can't go through
#      the hashed file: pip turns on hash-checking for every requirement
#      once any has a hash, and socialhome's own hash isn't in the file.)
# The final stage installs ``--no-index`` from this wheelhouse, so a lock
# that disagreed with socialhome's own requirements fails the build.
#
# Older tags: a tag without ``uv.lock`` (HTTP 404) falls back to the
# committed export ``requirements/constraints.txt`` (Social Home stopped
# committing it after 2026.10.17). Releases up to 2026.10.16 predate the
# lock entirely: for those (and only those) a 404 on both falls back to
# the old unlocked build with a warning. Any other outcome fails the
# build: a 404 for a newer version (a moved or deleted file never
# silently unlocks a release), any other HTTP status, a network error,
# or a failed export. Drop the fallbacks once both build.yaml pins are
# past the versions they cover.
RUN set -eu; \
    base="https://raw.githubusercontent.com/social-home-io/socialhome/${SOCIALHOME_VERSION}"; \
    mkdir -p /tmp/lock; \
    fetch() { curl -sSL -o "/tmp/lock/$(basename "$1")" -w '%{http_code}' "${base}/$1"; }; \
    fail() { echo "ERROR: HTTP $1 for $2 of socialhome ${SOCIALHOME_VERSION} (${base}/$2)" >&2; exit 1; }; \
    locked=1; \
    status="$(fetch uv.lock)"; \
    if [ "${status}" = 200 ]; then \
        status="$(fetch pyproject.toml)"; \
        [ "${status}" = 200 ] || fail "${status}" pyproject.toml; \
        uv export --no-cache --frozen --no-dev --no-emit-project --no-header \
            --format requirements-txt --project /tmp/lock > /tmp/lock/requirements.txt; \
    elif [ "${status}" = 404 ]; then \
        status="$(fetch requirements/constraints.txt)"; \
        if [ "${status}" = 200 ]; then \
            mv /tmp/lock/constraints.txt /tmp/lock/requirements.txt; \
        elif [ "${status}" = 404 ] && python3 -c 'import re, sys; v = lambda s: [int(n) for n in re.findall(r"[0-9]+", s)]; sys.exit(v(sys.argv[1]) > v(sys.argv[2]))' \
                "${SOCIALHOME_VERSION}" 2026.10.16; then \
            echo "WARNING: socialhome ${SOCIALHOME_VERSION} predates the dependency lock; building UNLOCKED" >&2; \
            locked=0; \
        else \
            fail "${status}" requirements/constraints.txt; \
        fi; \
    else \
        fail "${status}" uv.lock; \
    fi; \
    if [ "${locked}" = 1 ]; then \
        pip3 wheel --no-cache-dir --require-hashes --wheel-dir=/wheels \
            -r /tmp/lock/requirements.txt; \
        pip3 wheel --no-cache-dir --no-deps --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    else \
        pip3 wheel --no-cache-dir --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    fi; \
    rm -rf /tmp/lock

# ---------- final stage ------------------------------------------
FROM ${BUILD_FROM}

# Runtime libs — match the upstream ``socialhome/Dockerfile.sh``
# install list so behaviour parity holds.
# hadolint ignore=DL3018
RUN apk add --no-cache \
        ffmpeg \
        libjpeg-turbo \
        libwebp \
        libheif

ARG SOCIALHOME_VERSION
COPY --from=builder /wheels /tmp/wheels
RUN pip3 install --no-cache-dir --no-index --find-links=/tmp/wheels \
        "socialhome==${SOCIALHOME_VERSION}" \
 && rm -rf /tmp/wheels

# ``CUSTOM_COMPONENT_VERSION`` pins the matching ``ha-integration``
# release the add-on ships. The zip is fetched once at image-build
# time (online build context) and baked into ``/opt/socialhome``;
# the ``install-integration`` s6 oneshot then drops it into
# ``/homeassistant/custom_components/socialhome/`` on every boot
# without needing internet access at runtime. The bundled zip's
# own ``manifest.json::version`` is the source of truth — the
# oneshot reads it back via ``unzip -p`` so there's no second
# version label to keep in sync.
ARG CUSTOM_COMPONENT_VERSION
ADD https://github.com/social-home-io/ha-integration/releases/download/${CUSTOM_COMPONENT_VERSION}/socialhome.zip \
    /opt/socialhome/custom_component.zip

# rootfs ships the s6-overlay v3 service files
# (``/etc/s6-overlay/s6-rc.d/socialhome/``) plus the
# ``/etc/socialhome.toml.gtpl`` template.
COPY rootfs /

# Liveness probe — the Supervisor reads Docker's HEALTHCHECK state
# and restarts the add-on when ``/healthz`` (served by
# ``socialhome.routes.health``) stops answering. Uses the BusyBox
# ``wget`` that ships with the Alpine base, so no extra package.
# ``--start-period`` covers the s6 boot + DB migration window.
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8099/healthz > /dev/null || exit 1

# OCI labels — Supervisor surfaces ``io.hass.*`` in the add-on UI.
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.licenses="MPL-2.0" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}"
