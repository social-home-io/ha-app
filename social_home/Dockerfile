# syntax=docker/dockerfile:1.7
#
# Social Home — Home Assistant add-on (stable channel).
#
# Built on the official ``python:3.14-slim`` image (Debian slim).
# Mirrors the home-assistant/addons reference style (see
# ``configurator``): ``BUILD_FROM`` is filled in by ``build.yaml``,
# the pinned socialhome version comes through as a build-arg, and
# the package is installed straight from PyPI. The SPA bundle is
# baked into the upstream wheel by the socialhome publish workflow,
# so this image needs no node / pnpm.
#
# The HA add-on plumbing (s6-overlay init, bashio shell helpers,
# tempio template renderer) is layered on top so ``run.sh`` can
# read add-on options via ``bashio::config`` and render the runtime
# TOML on every start.

ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

ARG S6_OVERLAY_VERSION="3.2.0.2"
ARG BASHIO_VERSION="0.16.2"
ARG TEMPIO_VERSION="2024.11.2"

# System deps:
#  - bash, ca-certificates, curl, jq, xz-utils: HA add-on plumbing.
#  - ffmpeg, libjpeg-turbo-progs, libwebp-dev: socialhome runtime
#    (video transcoding + Pillow). Match the upstream
#    ``Dockerfile.sh`` install list so behaviour parity holds.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        ffmpeg \
        jq \
        libjpeg-turbo-progs \
        libwebp-dev \
        xz-utils \
 && rm -rf /var/lib/apt/lists/*

# s6-overlay — provides ``/init`` so ``CMD`` can drop privileges,
# stage env vars from ``/run/s6/container_environment``, and run
# the ``with-contenv`` shebang in ``run.sh``.
RUN ARCH="$(uname -m)" \
 && curl -fsSLo /tmp/s6-noarch.tar.xz \
        "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
 && curl -fsSLo /tmp/s6-arch.tar.xz \
        "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz" \
 && tar -C / -Jxpf /tmp/s6-noarch.tar.xz \
 && tar -C / -Jxpf /tmp/s6-arch.tar.xz \
 && rm /tmp/s6-*.tar.xz

# bashio — the shell library every Supervisor add-on uses to read
# ``options.json``, log with structured levels, and call the
# Supervisor API.
RUN curl -fsSLo /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/refs/tags/v${BASHIO_VERSION}.tar.gz" \
 && tar -C /tmp -xzf /tmp/bashio.tar.gz \
 && mv "/tmp/bashio-${BASHIO_VERSION}/lib" /usr/lib/bashio \
 && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
 && rm -rf /tmp/bashio.tar.gz "/tmp/bashio-${BASHIO_VERSION}"

# tempio — Go-template renderer maintained by Home Assistant. We
# feed it a JSON document on stdin and render
# ``social_home.toml.gtpl`` into ``/data/social_home.toml`` on
# every start.
RUN ARCH="$(uname -m)" \
 && case "${ARCH}" in \
        x86_64)  TEMPIO_ARCH=amd64 ;; \
        aarch64) TEMPIO_ARCH=aarch64 ;; \
        *)       echo "Unsupported tempio arch: ${ARCH}" >&2; exit 1 ;; \
    esac \
 && curl -fsSLo /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${TEMPIO_ARCH}" \
 && chmod a+x /usr/bin/tempio

# Install Social Home from PyPI. ``SOCIALHOME_VERSION`` is passed in
# from ``build.yaml`` so a CalVer bump there is enough to repin the
# install on the next Supervisor refresh. The SPA bundle ships
# inside the wheel under ``socialhome/static/``.
ARG SOCIALHOME_VERSION
RUN pip install --no-cache-dir "socialhome==${SOCIALHOME_VERSION}"

COPY rootfs /
COPY run.sh /run.sh
RUN chmod a+x /run.sh

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

CMD ["/init"]
