# syntax=docker/dockerfile:1.7
#
# Social Home — Home Assistant add-on (early-access channel).
#
# Same shape as ``socialhome/Dockerfile`` — see that file for the
# layer-by-layer rationale. The only deliberate difference is that
# ``--pre`` is passed to pip so the early channel can pin a CalVer
# pre-release (e.g. ``2026.5.11rc1``) before the same version is
# promoted to the stable add-on.

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
# Locked dependency set — see the stable Dockerfile for the rationale
# and the fallbacks for older tags. ``--pre`` lets the early channel pin
# a CalVer pre-release of socialhome itself; the locked deps are exact
# pins, so they need no ``--pre``.
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
        pip3 wheel --no-cache-dir --pre --no-deps --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    else \
        pip3 wheel --no-cache-dir --pre --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    fi; \
    rm -rf /tmp/lock

# ---------- final stage ------------------------------------------
FROM ${BUILD_FROM}

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

# Pinned ha-integration release — see the stable Dockerfile for the
# rationale (image-build-time fetch, runtime offline-only unzip).
ARG CUSTOM_COMPONENT_VERSION
ADD https://github.com/social-home-io/ha-integration/releases/download/${CUSTOM_COMPONENT_VERSION}/socialhome.zip \
    /opt/socialhome/custom_component.zip

COPY rootfs /

# Liveness probe — see the stable Dockerfile for the rationale.
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8099/healthz > /dev/null || exit 1

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
