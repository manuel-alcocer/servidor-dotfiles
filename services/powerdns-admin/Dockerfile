FROM alpine:3.7

LABEl Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ADD utils /root/utils/

RUN apk --update add --no-cache --virtual build_flask python3-dev mariadb-client \
    libldap libsasl libssl1.0 libxml2-dev libxslt-dev xmlsec-dev \
    libffi-dev mariadb-dev git yarn musl-dev openldap-dev gcc && \
    git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git \
        /opt/web/powerdns-admin && \
    cd /opt/web/powerdns-admin && pip3 install virtualenv && \
    virtualenv -p python3 flask && . ./flask/bin/activate && \
    pip3 --no-cache-dir install -r requirements.txt && apk del build_flask && \
    apk --update add --no-cache apache2 apache2-mod-wsgi
