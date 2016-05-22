#!/usr/bin/env sh

set -e

envsubst < /home/flexget/config.yml.tmpl > /home/flexget/config.yml

if [ ! -f /home/flexget/.flexget/config.yml ];
then
  # because /home/flexget/.flexget is a volume, we copy the file if it
  # doesn't exist, e.g. first-time boot (if the host volume doesn't provide a config file)
  cp /home/flexget/config.yml /home/flexget/.flexget/config.yml
fi

flexget web passwd "${FLEXGET_WEB_PASSWORD}"
exec flexget daemon start
