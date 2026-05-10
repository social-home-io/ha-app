# syntax=docker/dockerfile:1.7
#
# Social Home — Home Assistant add-on (dev channel).
#
# Same shape as ``social_home/Dockerfile`` — see that file for the
# layer-by-layer rationale. The only deliberate difference is that
# ``--pre`` is passed to pip so the dev channel can pin a CalVer
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
RUN pip3 wheel --no-cache-dir --pre --wheel-dir=/wheels \
        "socialhome==${SOCIALHOME_VERSION}"

# ---------- final stage ------------------------------------------
FROM ${BUILD_FROM}

# hadolint ignore=DL3018
RUN apk add --no-cache \
        ffmpeg \
        libjpeg-turbo \
        libwebp

ARG SOCIALHOME_VERSION
COPY --from=builder /wheels /tmp/wheels
RUN pip3 install --no-cache-dir --no-index --find-links=/tmp/wheels \
        "socialhome==${SOCIALHOME_VERSION}" \
 && rm -rf /tmp/wheels

COPY rootfs /

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
