#!/bin/bash
set -e

if [ "$1" = 'nginx' ]; then
    if [ ! -d "$DEBS_DIR" ];then
        echo "Mount your Debian package directory to $DEBS_DIR."
        exit 1
    fi

    if [ ! -f "$GNUPG_SUBKEYFILE" ]
    then
        echo "Mount your gnupg secret signing subkey to $GNUPG_SUBKEYFILE."
        exit 1
    fi
    gosu aptly gpg --import "$GNUPG_SUBKEYFILE"
    chgrp aptly "$GPG_PASSPHRASE_FILE"
    chmod g+r "$GPG_PASSPHRASE_FILE"
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
      gosu aptly aptly publish snapshot -passphrase-file=$GPG_PASSPHRASE_FILE "${APTLY_REPO_NAME}-0.1" 
    fi
    set -e
    
    exec "$@"
fi

exec "$@"
