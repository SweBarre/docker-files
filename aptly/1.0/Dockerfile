FROM debian:jessie
MAINTAINER "Jonas Forberg <jonas@rre.nu>"

RUN groupadd -r aptly && useradd -r -g aptly aptly
RUN mkdir -p /home/aptly/.aptly/public \
    && chown -R aptly:aptly /home/aptly

# add gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
        && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
        && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
        && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
        && export GNUPGHOME="$(mktemp -d)" \
        && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
        && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
        && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
        && chmod +x /usr/local/bin/gosu \
        && gosu nobody true \
        && apt-get purge -y --auto-remove ca-certificates wget

ENV NGINX_MAJOR 1.6.2
ENV NGINX_VERSION 1.6.2-5+deb8u2

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
   && rm -rf /var/lib/apt/lists/*


RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log 


# defaults for aptly
ENV APTLY_COMPONENT main
ENV APTLY_DISTRIBUTION jessie
ENV APTLY_COMPONENT main
ENV APTLY_REPO_NAME repo
ENV KEYSERVER keys.gnupg.net

ENV GNUPG_SUBKEYFILE /secret-subkeys
ENV DEBS_DIR /debs


# install aptly
RUN echo deb http://repo.aptly.info/ squeeze main >> /etc/apt/sources.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460
RUN apt-get update && \
    apt-get install -y aptly  \
                       xz-utils \
                       bzip2 && \
    rm -rf /var/lib/apt/lists/*

COPY aptly.nginx /etc/nginx/sites-enabled/aptly
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / #backwards compat

EXPOSE 80 443
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
