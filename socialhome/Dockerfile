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
RUN pip3 wheel --no-cache-dir --wheel-dir=/wheels \
        "socialhome==${SOCIALHOME_VERSION}"

# ---------- final stage ------------------------------------------
FROM ${BUILD_FROM}

# Runtime libs — match the upstream ``socialhome/Dockerfile.sh``
# install list so behaviour parity holds.
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
