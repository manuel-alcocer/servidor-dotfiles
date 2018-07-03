FROM alpine:3.7 as pdnsadmin_builder

RUN apk --update add --no-cache --virtual pdnsadmin-builder \
    libldap libsasl libssl1.0 libxml2-dev libxslt-dev xmlsec-dev \
    libffi-dev git musl-dev gcc yarn python3-dev mariadb-dev \
    openldap-dev && \
    git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git \
        /opt/web/powerdns-admin && \
    cd /opt/web/powerdns-admin && pip3 install virtualenv && \
    virtualenv -p python3 flask && . ./flask/bin/activate && \
    pip3 --no-cache-dir install -r requirements.txt


FROM alpine:3.7

LABEl Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

RUN apk --update add --no-cache bash mariadb-client-libs yarn python3-dev openldap-dev \
    mariadb-client uwsgi-python3 && addgroup pdnsadmin && adduser -DG pdnsadmin pdnsadmin

ADD --chown=pdnsadmin:pdnsadmin utils /root/utils/

COPY --from=pdnsadmin_builder --chown=pdnsadmin:pdnsadmin /opt/web /opt/web/
