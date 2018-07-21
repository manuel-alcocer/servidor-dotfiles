FROM alpine:3.7

LABEL Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ADD entrypoint.sh /

RUN apk --update add --no-cache openldap openldap-back-mdb openldap-overlay-all bash \
    vim openldap-clients

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
