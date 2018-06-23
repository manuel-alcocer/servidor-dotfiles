FROM debian:latest
LABEl Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ENV DEBIAN_FRONTEND noninteractive

RUN echo  "pdns-backend-mysql      pdns-backend-mysql/app-password-confirm password admin.1234" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/password-confirm     password admin.1234" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/mysql/app-pass       password admin.1234" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/mysql/admin-pass     password eeQuah4a" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/remote/host  select  mariadb" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/db/dbname    string  pdns" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/upgrade-backup       boolean false" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/dbconfig-install     boolean false" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/remote/newhost       string  mariadb" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/remote/port  string  3306" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/mysql/method select  TCP/IP" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/db/app-user  string  pdns@%" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/database-type        select  mysql" > pdnspreseed && \
    echo  "pdns-backend-mysql      pdns-backend-mysql/dbconfig-upgrade     boolean false" > pdnspreseed && \
    debconf-set-selections pdnspreseed && \
    echo exit 101 > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d && \
    apt-get update && apt-get install -y pdns-server pdns-backend-mysql && \
    echo "while :; do sleep 5; done" > /root/entry.sh

ENTRYPOINT ["/bin/bash", "/root/entry.sh"]

