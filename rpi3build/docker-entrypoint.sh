#!/bin/bash

if [ "$1" == "docker-entrypoint.sh" ] || [ -z ${1+x} ];then
  if [ -z ${DEBEMAIL+x} ];then
    echo 'you have to set $DEBEMAIL'
    exit 1
  fi
  if [ -z ${DEBFULLNAME+x} ];then
    echo 'you have to set $DEBFULLNAME'
    exit 1
  fi
  if [ ! -d /debs ];then
    echo "you have to mount /debs volume"
    exit 1
  fi
  if [ -z ${CHANGE_MESSAGE+x} ];then
    echo "setting default change message"
    CHANGE_MESSAGE="My kernel build"
  fi
  if [ ! -f /root/src/linux/.config ];then
    echo "you have to create a config first"
    exit 1
  fi

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

  while true; do
    apt-get update
    KERNEL_VERSION="$(apt-cache show raspberrypi-kernel | sed -n 's/Version: \(.*\).*/\1/p')"
    KERNEL_DESTINATION="/root/src/raspberrypi-firmware-$(echo $KERNEL_VERSION | sed -n 's/\(.*\)-.*/\1/p')"
    if [ ! -d "$KERNEL_DESTINATION" ];then
      cd /root/src
      apt-get source raspberrypi-kernel
  
      cd /root/src/linux
      git pull
      make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE" zImage modules dtbs
      make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE" INSTALL_MOD_PATH="$KERNEL_DESTINATION" modules_install
      scripts/mkknlimg arch/arm/boot/zImage "$KERNEL_DESTINATION/boot/$KERNEL.img"  
      cp arch/arm/boot/dts/*.dtb "$KERNEL_DESTINATION"
      cp arch/arm/boot/dts/overlays/*.dtb* "$KERNEL_DESTINATION/boot/overlays/"
      cp arch/arm/boot/dts/overlays/README "$KERNEL_DESTINATION/boot/overlays/"
  
      cd "$KERNEL_DESTINATION"
      dch -i --distribution stable "$CHANGE_MESSAGE" 
      fakeroot debian/rules binary
      # publish debs n aptly
      if [ ! -z ${APTLY_SERVER+x} ];then
        cd /root/src
        FILES=*.deb
        for f in $FILES
        do
          curl -X POST -F file="@$f" "http://$APTLY_SERVER:$APTLY_SERVER_PORT/api/files/${f%.deb}" 
          curl -X POST "http://$APTLY_SERVER:$APTLY_SERVER_PORT/api/repos/$APTLY_REPO/file/${f%.deb}"
        done
        curl  -X PUT -H 'Content-Type: application/json' \
            --data "{\"Signing\": {\"Batch\": true, \"PassphraseFile\": \"$APTLY_PASSFILE\", \"SecretKeyring\": \"$APTL_SIGN_KEY\"}}" \
            "http://$APTLY_SERVER:$APTLY_SERVER_PORT/api/publish/:./$APTLY_DISTRIBUTION"
      fi

      mv /root/src/*.deb /debs
      if [ ! -z ${FINAL_UID+x} ];then
        chown "$FINAL_UID":"$FINAL_UID" /debs/*.deb
      fi
    fi
    echo "$(date "+%Y-%m-%d %H:%S:%m")  Sleeping for four hours..."
    sleep 4h
  done



elif [ "$1" == "menuconfig" ];then
  cd /root/src/linux
  if [ ! -d /config_output ];then
    echo "you have to mount /config_output"
    exit 1
  fi
  if [ -f /config_output/config ];then
    cp /config_output/config /root/src/linux/.config
  else
    cp /root/src/linux/arch/arm/configs/bcm2709_defconfig /root/src/linux/.config
  fi
  make ARCH=arm menuconfig
  cp .config /config_output/config
  if [ ! -z ${FINAL_UID+x} ];then
    chown "$FINAL_UID":"$FINAL_UID" /config_output/config
  fi
else
  exec "$@"
fi
