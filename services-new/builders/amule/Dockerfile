FROM alpine:latest

LABEL Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

RUN printf 'http://dl-cdn.alpinelinux.org/alpine/edge/testing\n' >> /etc/apk/repositories && \
    apk upgrade --no-cache && apk --update add --no-cache amule crypto++ bash git && \
    ln -s /usr/lib/libcryptopp.so /usr/lib/libcryptopp.so.5.6 && \
    adduser -Dh /var/lib/amule -s /bin/false -u 1000 amule amule && \
    su - -s /bin/sh amule -c 'amuled' && \
    sed -ri 's/AcceptExternalConnections.*$/AcceptExternalConnections=1/' \
        /var/lib/amule/.aMule/amule.conf

ADD entrypoint.sh /

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
