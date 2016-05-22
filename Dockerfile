FROM debian:jessie

# Update packages and install software
ENV DEBIAN_FRONTEND noninteractive

RUN groupadd -r flexget && useradd -r -g flexget flexget

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
  && rm -rf /var/lib/apt/lists/*

ENV GOSU_VERSION 1.7
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN apt-get update && apt-get install -y \
  gettext-base \
&& rm -rf /var/lib/apt/lists/*

RUN apt-get update

RUN apt-get update && apt-get install -y \
  python-pip \
  python-setuptools \
&& rm -rf /var/lib/apt/lists/* \
&& pip install flexget

ENV "FLEXGET_USER_ID=" \
  "FLEXGET_GROUP_ID=" \
  "FLEXGET_WEB_PASSWORD=" \
  "FLEXGET_WEB_PORT="

COPY entrypoint.sh /
COPY flexget-daemon.sh /

# copy the config into a "default" location,
# because we create /home/flexget/.flexget as a volume
COPY config.yml.tmpl /home/flexget/config.yml.tmpl
RUN chown -R flexget:flexget /home/flexget

RUN mkdir /data
RUN mkdir /data/downloads
RUN mkdir /data/media
RUN chown -R flexget:flexget /data

VOLUME /data/downloads
VOLUME /data/media

VOLUME /home/flexget/.flexget

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/flexget-daemon.sh"]
