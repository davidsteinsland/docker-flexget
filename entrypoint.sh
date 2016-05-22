#!/usr/bin/env bash

set -e

if [ "$1" = '/flexget-daemon.sh' ];
then
  if [ ! -z "${FLEXGET_USER_ID}" ];
  then
    echo "Changing UID to $FLEXGET_USER_ID"
    usermod -u $FLEXGET_USER_ID -o flexget
  fi

  if [ ! -z "${FLEXGET_GROUP_ID}" ];
  then
    echo "Changing GID to $FLEXGET_GROUP_ID"
    groupmod -g $FLEXGET_GROUP_ID -o flexget
  fi

  exec gosu flexget "$@"
fi

exec "$@"
