# syntax = docker/dockerfile:1
# requires DOCKER_BUILDKIT=1 set when running docker build
FROM debian:11.6-slim

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_URL
ARG VCS_REF
ARG VCS_BRANCH

# See http://label-schema.org/rc1/ and https://microbadger.com/labels
LABEL maintainer="Jan Wagner <waja@cyconet.org>" \
    org.label-schema.name="Mojolicious container" \
    org.label-schema.description="Debian Linux container with installed mojolicious package" \
    org.label-schema.vendor="Cyconet" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE:-unknown}" \
    org.label-schema.version="${BUILD_VERSION:-unknown}" \
    org.label-schema.vcs-url="${VCS_URL:-unknown}" \
    org.label-schema.vcs-ref="${VCS_REF:-unknown}" \
    org.label-schema.vcs-branch="${VCS_BRANCH:-unknown}" \
    org.opencontainers.image.source="https://github.com/waja/docker-mojolicious"

# hadolint ignore=DL3017,DL3008
RUN --mount=type=cache,target=/var/log \
    --mount=type=cache,target=/var/cache \
    --mount=type=tmpfs,target=/tmp \
    <<EOF
    # Create apache group and user
    addgroup --system apache && adduser --system --no-create-home --home /nonexistent --group apache
    # Creating mojolicious directory for storing the src files
    mkdir -p /var/www/mojolicious \
        && chmod -R 755 /var/www/mojolicious \
        && chown -R apache:apache /var/www/mojolicious
    apt-get update && apt-get -y upgrade
    # Install needed packages
    apt-get -y install --no-install-recommends libmojolicious-perl libdata-serializer-perl libfreezethaw-perl liblist-moreutils-perl
    apt-get -y autoremove --purge
    rm -rf /var/lib/apt/lists/* /tmp/*
    # create needed directories
    mkdir -p /var/log/mojolicious/
    # forward request and error logs to docker log collector
    # See https://github.com/moby/moby/issues/19616
    ln -sf /proc/1/fd/1 /var/log/mojolicious/mojolicious.log
EOF

EXPOSE 8080 3000

STOPSIGNAL SIGTERM

# Run a shell as the default command
CMD ["/bin/sh"]
