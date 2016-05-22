#!/usr/bin/env sh

set -e

if [ "$1" = '/flexget-daemon.sh' ];
then
  if [ ! -z "${FLEXGET_GROUP_ID}" ];
  then
    echo "Changing GID to $FLEXGET_GROUP_ID"
    #groupmod -g $FLEXGET_GROUP_ID -o flexget

    delgroup flexget
    addgroup -S -g $FLEXGET_GROUP_ID flexget
  fi

  if [ ! -z "${FLEXGET_USER_ID}" ];
  then
    echo "Changing UID to $FLEXGET_USER_ID"
    #usermod -u $FLEXGET_USER_ID -o flexget

    deluser flexget
    adduser -S -u $FLEXGET_USER_ID -G flexget flexget
  fi

  chown -R flexget:flexget /home/flexget

  exec gosu flexget "$@"
fi

exec "$@"
