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

ARG SOCIALHOME_VERSION
# Locked dependency set. Every Social Home release commits
# ``requirements/constraints.txt`` (exported from its ``uv.lock``): every
# runtime package, transitive ones included, at an exact version with
# the sha256 of each published file. It is fetched for exactly
# ``SOCIALHOME_VERSION`` (by git tag, online build like the integration
# zip below), then:
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
# Transition: releases up to 2026.10.14 predate the lock. For those
# (and only those) an HTTP 404 falls back to the old unlocked build with
# a warning. Any other outcome fails the build: a 404 for a newer
# version (a moved or deleted file never silently unlocks a release),
# any other HTTP status, or a network error. Drop the fallback once
# both build.yaml pins are past 2026.10.14.
RUN set -eu; \
    url="https://raw.githubusercontent.com/social-home-io/socialhome/${SOCIALHOME_VERSION}/requirements/constraints.txt"; \
    status="$(curl -sSL -o /tmp/constraints.txt -w '%{http_code}' "${url}")"; \
    if [ "${status}" = 200 ]; then \
        pip3 wheel --no-cache-dir --require-hashes --wheel-dir=/wheels \
            -r /tmp/constraints.txt; \
        pip3 wheel --no-cache-dir --no-deps --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    elif [ "${status}" = 404 ] && python3 -c 'import re, sys; v = lambda s: [int(n) for n in re.findall(r"[0-9]+", s)]; sys.exit(v(sys.argv[1]) > v(sys.argv[2]))' \
            "${SOCIALHOME_VERSION}" 2026.10.14; then \
        echo "WARNING: socialhome ${SOCIALHOME_VERSION} predates the dependency lock; building UNLOCKED" >&2; \
        pip3 wheel --no-cache-dir --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    else \
        echo "ERROR: HTTP ${status} for requirements/constraints.txt of socialhome ${SOCIALHOME_VERSION} (${url})" >&2; \
        exit 1; \
    fi; \
    rm -f /tmp/constraints.txt

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
