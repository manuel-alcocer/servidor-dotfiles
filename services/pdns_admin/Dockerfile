FROM debian:latest
LABEl Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ENV DEBIAN_FRONTEND noninteractive

ADD utils /root/utils/

#RUN apt-get update && \
#    apt-get -y install python3-dev python3-pip mariadb-client \
#    libsasl2-dev libldap2-dev libssl-dev \
#    libxml2-dev libxslt1-dev libxmlsec1-dev \
#    libffi-dev pkg-config python3-mysqldb libmariadbclient-dev \
#    git apt-transport-https curl apache2 libapache2-mod-wsgi-py3 && \
#    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#    printf "deb https://dl.yarnpkg.com/debian/ stable main\n" \
#        > /etc/apt/sources.list.d/yarn.list && \
#    apt-get update && apt-get -y install yarn && \
#    git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git \
#        /opt/web/powerdns-admin && \
#    cd /opt/web/powerdns-admin && pip3 install virtualenv && \
#    virtualenv -p python3 flask && . ./flask/bin/activate && \
#    pip3 install -r requirements.txt && \
#    cp /root/utils/000-default.conf /etc/apache2/sites-enabled && \
#    cp /root/utils/powerdnsadmin.wsgi /opt/web/powerdns-admin && \
#    cp /root/utils/config.py /opt/web/powerdns-admin/config.py


RUN apt-get update && apt-get -y install mariadb-client

ENTRYPOINT ["/bin/bash", "/root/utils/pdns_admin.sh"]

