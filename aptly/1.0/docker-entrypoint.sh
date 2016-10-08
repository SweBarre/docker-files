#!/bin/bash
set -e

if [ "$1" = 'nginx' ]; then
    if [ ! -d /debs ];then
        echo "Mount your Debian package directory to /debs"
        exit 1
    fi

    if [ ! -f /sign-key ]
    then
        echo "Mount your gnupg secret signing subkey to /sign-key"
        exit 1
    fi
    if [ ! -f /.passfile ]
    then
      echo "You must mount your password to your signing key in /.passfile"
      exit 1
    fi
    gosu aptly gpg --import /sign-key
    chgrp aptly /.passfile
    chmod 0640 /.passfile
    # check if repo exists
    set +e
    gosu aptly aptly repo show "$APTLY_REPO_NAME"
    if [ $? -ne 0 ];then
      set -e
      gosu aptly gpg --armor --export > /home/aptly/.aptly/public/archive.key
      gosu aptly aptly repo create -distribution="$APTLY_DISTRIBUTION" \
          -component="$APTLY_COMPONENT" \
          "$APTLY_REPO_NAME"
      gosu aptly aptly repo add "$APTLY_REPO_NAME" "$DEBS_DIR"
      gosu aptly aptly repo show --with-packages "$APTLY_REPO_NAME"
      gosu aptly aptly snapshot create "${APTLY_REPO_NAME}-0.1" from repo "$APTLY_REPO_NAME"
      set +e 
      gosu aptly aptly publish snapshot -passphrase-file=/.passfile "${APTLY_REPO_NAME}-0.1" 
    fi
    set -e
    
    exec "$@"
fi

exec "$@"
