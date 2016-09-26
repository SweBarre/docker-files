#!/bin/bash
set -e

if [ -z $DATADIR ]; then
  DATADIR=/var/lib/mysql
fi

if [ "$1" = 'mysqld' ]; then
    chown -R mysql "$DATADIR"

    if [ -z "$(ls -A "$DATADIR")" ]; then
        gosu mysql mysql_install_db --skip-name-resolve \
          --datadir="$DATADIR" \
          --verbose \
          --user="mysql"
    fi

    exec gosu mysql "$@"
fi

exec "$@"
