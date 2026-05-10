# syntax=docker/dockerfile:1.7
#
# Social Home — Home Assistant add-on (dev channel).
#
# Same shape as the stable ``social_home/Dockerfile`` — see that
# file for the layer-by-layer rationale. The only deliberate
# difference is the version pin: this channel can ride ahead of
# stable by bumping ``SOCIALHOME_VERSION`` in ``build.yaml`` (e.g.
# to a CalVer pre-release like ``2026.5.11rc1``) before the same
# version is promoted to the stable add-on.

ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

ARG S6_OVERLAY_VERSION="3.2.0.2"
ARG BASHIO_VERSION="0.16.2"
ARG TEMPIO_VERSION="2024.11.2"

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

RUN ARCH="$(uname -m)" \
 && curl -fsSLo /tmp/s6-noarch.tar.xz \
        "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
 && curl -fsSLo /tmp/s6-arch.tar.xz \
        "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz" \
 && tar -C / -Jxpf /tmp/s6-noarch.tar.xz \
 && tar -C / -Jxpf /tmp/s6-arch.tar.xz \
 && rm /tmp/s6-*.tar.xz

RUN curl -fsSLo /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/refs/tags/v${BASHIO_VERSION}.tar.gz" \
 && tar -C /tmp -xzf /tmp/bashio.tar.gz \
 && mv "/tmp/bashio-${BASHIO_VERSION}/lib" /usr/lib/bashio \
 && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
 && rm -rf /tmp/bashio.tar.gz "/tmp/bashio-${BASHIO_VERSION}"

RUN ARCH="$(uname -m)" \
 && case "${ARCH}" in \
        x86_64)  TEMPIO_ARCH=amd64 ;; \
        aarch64) TEMPIO_ARCH=aarch64 ;; \
        *)       echo "Unsupported tempio arch: ${ARCH}" >&2; exit 1 ;; \
    esac \
 && curl -fsSLo /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${TEMPIO_ARCH}" \
 && chmod a+x /usr/bin/tempio

# Install Social Home from PyPI. Pre-releases are allowed so the
# dev channel can pin a CalVer release-candidate before it lands on
# the stable add-on.
ARG SOCIALHOME_VERSION
RUN pip install --no-cache-dir --pre "socialhome==${SOCIALHOME_VERSION}"

COPY rootfs /
COPY run.sh /run.sh
RUN chmod a+x /run.sh

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
