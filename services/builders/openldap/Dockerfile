FROM alpine:3.7

LABEL Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ADD entrypoint.sh /

ENV SUFFIX=dc\=myhome,dc\=local ROOTPW=openldap ROOTDN=cn\=admin,dc\=myhome,dc\=local

RUN apk --update add --no-cache openldap openldap-back-mdb openldap-overlay-all bash \
    vim openldap-clients

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]

