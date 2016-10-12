FROM ubuntu:16.04
WORKDIR /root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      git \
      build-essential \
      lsb-release \
      dialog \
      binutils \
      curl \
      ca-certificates \
   && rm -rf /var/lib/apt/lists/* \
   && git clone https://github.com/igorpecovnik/lib
RUN cp lib/compile.sh .
RUN mkdir -p /root/output/debs
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / #backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-entrypoint.sh"]
