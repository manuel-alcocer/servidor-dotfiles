FROM alpine:3.7

LABEL Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ADD daemon/daemon.sh /etc/openldap/

RUN apk --update add --no-cache openldap openldap-back-mdb openldap-overlay-all bash && \
    . /run/secrets/openldap_pw && sed -ri 's/^(suffix\s).*$/\1'"${SUFFIX}"'/' \
        /etc/openldap/slapd.conf && sed -ri 's/^(rootpw\s).*$/\1'"${ROOT_PW}"'/' \
        /etc/openldap/slapd.conf

