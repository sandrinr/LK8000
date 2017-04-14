FROM ubuntu:xenial

EXPOSE 873

COPY rsyncd.conf /etc/rsyncd.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN true && \
    apt-get update && \
    apt-get install -y --no-install-recommends sudo rsync wget \
        ca-certificates pkg-config build-essential crossbuild-essential-armhf \
        xsltproc imagemagick ttf-dejavu fakeroot zip && \
    mkdir /lk8000 && chown nobody:nogroup /lk8000 && \
    chmod 0755 /usr/local/bin/entrypoint.sh && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/log/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
