#!/usr/bin/env sh

set -e

if [ "$1" = '/flexget-daemon.sh' ];
then
  if [ ! -z "${FLEXGET_GROUP_ID}" ];
  then
    echo "Changing GID to $FLEXGET_GROUP_ID"
    #groupmod -g $FLEXGET_GROUP_ID -o flexget

    # remove user flexget from group flexget
    deluser flexget

    # add group with new ID
    addgroup -S -g $FLEXGET_GROUP_ID flexget
    # re-add user flexget to group
    echo "Changing UID to $FLEXGET_USER_ID"
    adduser -S -G flexget -u $FLEXGET_USER_ID flexget
  fi

  chown -R flexget:flexget /home/flexget

  exec gosu flexget "$@"
fi

exec "$@"
