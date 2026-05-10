# syntax=docker/dockerfile:1.7
#
# Social Home — Home Assistant add-on (stable channel).
#
# Built on the official Home Assistant Python base image, which
# ships Alpine + s6-overlay v3 + bashio + tempio + ``/usr/local``
# Python 3.14 with pip already wired up to the HA musllinux wheel
# index. Mirrors the home-assistant/addons reference style (see
# e.g. ``silabs_flasher``).
#
# The SPA bundle is baked into the upstream socialhome wheel by the
# socialhome publish workflow, so the image needs no node / pnpm.

ARG BUILD_FROM
FROM ${BUILD_FROM}

# Runtime libs — match the upstream ``socialhome/Dockerfile.sh``
# install list so behaviour parity holds. ffmpeg powers SpacePost /
# BazaarListing video transcoding; libjpeg-turbo + libwebp are
# Pillow's runtime deps for JPEG / WebP IO.
RUN apk add --no-cache \
        ffmpeg \
        libjpeg-turbo \
        libwebp

# Install Social Home from PyPI. ``SOCIALHOME_VERSION`` comes from
# ``build.yaml`` so a CalVer bump there repins the install on the
# next Supervisor refresh. The HA base image's pip is already
# configured with ``PIP_EXTRA_INDEX_URL`` pointing at the HA
# musllinux wheel index, which gives us prebuilt wheels for the
# native deps (cryptography, av, aiolibdatachannel, ...) on Alpine.
ARG SOCIALHOME_VERSION
RUN pip3 install --no-cache-dir "socialhome==${SOCIALHOME_VERSION}"

# rootfs ships the s6-overlay v3 service files
# (``/etc/s6-overlay/s6-rc.d/socialhome/``) plus the
# ``/etc/social_home.toml.gtpl`` template.
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
