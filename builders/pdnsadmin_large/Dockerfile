FROM debian:latest

LABEl Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install python3-dev python3-pip mariadb-client \
    libsasl2-dev libldap2-dev libssl-dev \
    libxml2-dev libxslt1-dev libxmlsec1-dev \
    libffi-dev pkg-config python3-mysqldb libmariadbclient-dev \
    git apt-transport-https curl && \
    #git apt-transport-https curl apache2 libapache2-mod-wsgi-py3 && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    printf "deb https://dl.yarnpkg.com/debian/ stable main\n" \
        > /etc/apt/sources.list.d/yarn.list && \
    apt-get -y install yarn && \
    git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git \
        /opt/web/powerdns-admin && \
    cd /opt/web/powerdns-admin && pip3 install virtualenv && \
    virtualenv -p python3 flask && . ./flask/bin/activate && \
    pip3 install -r requirements.txt && \
    apt-get -y remove --purge python3-dev python3-pip mariadb-client \
    libsasl2-dev libldap2-dev libssl-dev \
    libxml2-dev libxslt1-dev libxmlsec1-dev \
    libffi-dev pkg-config python3-mysqldb libmariadbclient-dev \
    git apt-transport-https curl
