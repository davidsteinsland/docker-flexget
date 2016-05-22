FROM alpine:3.3

RUN addgroup -S flexget && adduser -S -G flexget flexget

ENV GOSU_VERSION 1.7
RUN set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        openssl \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apk del .gosu-deps

RUN apk add --no-cache python && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache

RUN apk add --update ca-certificates gettext && rm -rf /var/cache/apk/*

RUN pip install -I flexget

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
