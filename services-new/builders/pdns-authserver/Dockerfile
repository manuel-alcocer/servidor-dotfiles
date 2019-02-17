FROM alpine:3.7

LABEl Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

RUN apk --update add --no-cache bash pdns pdns-backend-mysql pdns-doc mariadb-client gettext

ADD entrypoint.sh /

ENTRYPOINT ["/bin/bash", "/entrypoint.sh", "start"]
