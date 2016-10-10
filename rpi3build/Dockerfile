FROM debian:jessie
RUN apt-get update && apt-get install --no-install-recommends -y \
  git \
  curl \
  build-essential \
  kernel-package \
  fakeroot \
  debhelper \
  devscripts \
  libncurses5-dev \
  libfile-fcntllock-perl \
  libdistro-info-perl \
  libparse-debcontrol-perl \
  quilt \
  cpio \
  bc \
  vim \
  ca-certificates \
  curl \
  apt-transport-https \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /root/src
WORKDIR /root/src
RUN git clone https://github.com/raspberrypi/tools
RUN git clone --depth=1 https://github.com/raspberrypi/linux
RUN curl https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add - \
    && echo "deb-src https://archive.raspberrypi.org/debian/ jessie main ui" >> /etc/apt/sources.list.d/raspi.list \
    && echo "deb [arch=armhf] https://archive.raspberrypi.org/debian/ jessie main ui" >> /etc/apt/sources.list.d/raspi.list \
    && dpkg --add-architecture armhf \
    && rm -rf /var/lib/apt/lists/*
ENV PATH="/root/src/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin:${PATH}"
ENV KERNEL=kernel7
ENV DEB_HOST_ARCH=armhf
ENV AUFS=aufs4.7
ENV ARCH=arm 
ENV CROSS_COMPILE=arm-linux-gnueabihf-
WORKDIR /root
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / #backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-entrypoint.sh"]
