FROM alpine:3.14.0

WORKDIR /goaccess

ARG build_deps="build-base ncurses-dev autoconf automake git gettext-dev geoip-dev wget zlib-dev bzip2-dev"
ARG runtime_deps="tini ncurses libintl gettext openssl-dev geoip zlib libbz2"

RUN apk add --no-cache -u $runtime_deps $build_deps && \
    git clone https://github.com/allinurl/goaccess /goaccess && \
    wget -nv http://fallabs.com/tokyocabinet/tokyocabinet-1.4.48.tar.gz -O - | tar zxf - && \
    cd tokyocabinet-1.4.48 && \
      ./configure --prefix=/usr --enable-off64 --enable-fastest && \
      make -j$(nproc) && \
      make install && \
    cd /goaccess && \
      autoreconf -fiv && \
      ./configure --enable-utf8 --with-openssl --with-getline --enable-geoip=legacy --enable-tcb=btree && \
      make -j$(nproc) && \
      make install && \
    apk del $build_deps && \
    rm -rf /goaccess

VOLUME /srv/data
VOLUME /srv/logs
VOLUME /srv/report
EXPOSE 7890

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["goaccess", "--no-global-config", "--config-file=/srv/data/goaccess.conf"]
