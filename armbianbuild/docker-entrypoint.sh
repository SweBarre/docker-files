#!/bin/bash
set -e
if [[ "$1" == "compile" ]] || [[ -z ${1+x} ]];then
  if [ -z ${APTLY_SERVER_PORT+x} ];then
    APTLY_SERVER_PORT=8080
  fi

  if [ -z ${APTLY_REPO+x} ];then
    APTLY_REPO=repo
  fi

  if [ -z ${APTLY_COMPONENT+x} ];then
    APTLY_COMPONENT=main
  fi

  if [ -z ${APTLY_DISTRIBUTION+x} ];then
    APTLY_DISTRIBUTION=jessie
  fi
  while true;
  do
    cd /root/lib
    log=$(git fetch && git rev-list master..origin/master)
    if [[ "$log" != "" ]];then
      git pull
      cd /root
      cp lib/compile.sh .
      exec ./compile.sh $COMPILE_OPTIONS
      if [ ! -z ${APTLY_SERVER+x} ];then
        cd /root/output/debs
        FILES=*.deb
        for f in $FILES
        do
          curl -X POST -F file="@$f" "http://$APTLY_SERVER:$APTLY_SERVER_PORT/api/files/${f%.deb}" 
          curl -X POST "http://$APTLY_SERVER:$APTLY_SERVER_PORT/api/repos/$APTLY_REPO/file/${f%.deb}"
        done
        curl -X PUT -H 'Content-Type: application/json' \
            --data "{\"Signing\": {\"Batch\": true, \"PassphraseFile\": \"$APTLY_PASSFILE\", \"SecretKeyring\": \"$APTL_SIGN_KEY\"}}" \
            "http://$APTLY_SERVER:$APTLY_SERVER_PORT/api/publish/:./$APTLY_DISTRIBUTION"
      fi
      if [[ -d /debs ]]; then
        mv *.deb /debs
        if [[ -z ${FINAL_UID} ]]; then
          chown "$FINAL_UID":"$FINAL_UID" /debs/*.deb
        fi
      fi
    fi
     echo "$(date "+%Y-%m-%d %H:%S:%m")  Sleeping for four hours..."
    sleep 4h
  done
elif [[ "$1" == "config" ]];then
    cd /root
  exec ./compile.sh $COMPILE_OPTIONS KERNEL_CONFIGURE=yes
else
  exec "$@"
fi
set +e
