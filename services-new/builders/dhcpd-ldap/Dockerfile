FROM debian:latest

LABEL Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ENV INTERFACES="eth0"

ENV LDAP_SERVER="myhome.local"
ENV LDAP_PORT="389"
ENV LDAP_USERNAME="cn=dhcpd,ou=Users,dc=myhome,dc=local"
ENV LDAP_PASSWORD="dhcpd.1234"
ENV LDAP_BASE_DN="ou=dhcpd,ou=Services,dc=myhome,dc=local"
ENV LDAP_METHOD="dynamic"
ENV LDAP_DEBUG_FILE="/var/log/dhcp-ldap-startup.log"

ADD entrypoint.sh /

RUN apt-get -y update && apt-get -y install isc-dhcp-server isc-dhcp-server-ldap vim

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]

