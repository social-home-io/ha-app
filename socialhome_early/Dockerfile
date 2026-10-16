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

ARG SOCIALHOME_VERSION
# Locked dependency set — see the stable Dockerfile for the rationale
# and the transition rule. ``--pre`` lets the early channel pin a
# CalVer pre-release of socialhome itself; the locked deps are exact
# pins, so they need no ``--pre``.
RUN set -eu; \
    url="https://raw.githubusercontent.com/social-home-io/socialhome/${SOCIALHOME_VERSION}/requirements/constraints.txt"; \
    status="$(curl -sSL -o /tmp/constraints.txt -w '%{http_code}' "${url}")"; \
    if [ "${status}" = 200 ]; then \
        pip3 wheel --no-cache-dir --require-hashes --wheel-dir=/wheels \
            -r /tmp/constraints.txt; \
        pip3 wheel --no-cache-dir --pre --no-deps --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    elif [ "${status}" = 404 ] && python3 -c 'import re, sys; v = lambda s: [int(n) for n in re.findall(r"[0-9]+", s)]; sys.exit(v(sys.argv[1]) > v(sys.argv[2]))' \
            "${SOCIALHOME_VERSION}" 2026.10.14; then \
        echo "WARNING: socialhome ${SOCIALHOME_VERSION} predates the dependency lock; building UNLOCKED" >&2; \
        pip3 wheel --no-cache-dir --pre --wheel-dir=/wheels \
            "socialhome==${SOCIALHOME_VERSION}"; \
    else \
        echo "ERROR: HTTP ${status} for requirements/constraints.txt of socialhome ${SOCIALHOME_VERSION} (${url})" >&2; \
        exit 1; \
    fi; \
    rm -f /tmp/constraints.txt

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
