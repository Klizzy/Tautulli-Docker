FROM alpine:3.7

# set version for s6 overlay
ARG OVERLAY_VERSION="v1.21.4.0"
ARG OVERLAY_ARCH="amd64"

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
HOME="/root" \
TERM="xterm"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
  autoconf \
  automake \
  curl \
  g++ \
  gcc \
  linux-headers \
  make \
  python2-dev \
  tar && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
  bash \
  coreutils \
  curl \
  git \
  py2-lxml \
  py2-pip \
  python2 \
  shadow \
  tar \
  tzdata \
  vnstat \
  wget && \
  echo "**** install pip packages ****" && \
  pip install --no-cache-dir -U \
  pip && \
  pip install --no-cache-dir -U \
  plexapi \
  pycryptodomex \
  pyopenssl && \
  echo "**** add s6 overlay ****" && \
  curl -o \
  /tmp/s6-overlay.tar.gz -L \
  "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
  tar xfz \
  /tmp/s6-overlay.tar.gz -C / && \
  echo "**** create abc user and make folders ****" && \
  groupmod -g 1000 users && \
  useradd -u 911 -U -d /config -s /bin/false abc && \
  usermod -G users abc && \
  mkdir -p \
  /app \
  /config \
  /defaults && \
  echo "**** cleanup ****" && \
  apk del --purge \
  build-dependencies && \
  rm -rf \
  /root/.cache \
  /tmp/*

# add local files
COPY root/ /

ENTRYPOINT ["/init"]

# ports and volumes
VOLUME /config /logs
EXPOSE 8181
