FROM bardak/debian:jessie
RUN apt-get update && apt-get install -y --no-install-recommends python2.7 \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /web
WORKDIR /web
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / #backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 8000
CMD ["python2.7","-m","SimpleHTTPServer"]
