FROM debian:latest

LABEL Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ADD entrypoint.sh /

RUN apt-get -y update && apt-get -y install isc-dhcp-server isc-dhcp-server-ldap vim

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
