FROM debian:latest
LABEl Maintainer Manuel Alcocer Jiménez <manuel@alcocer.net>

ENV DEBIAN_FRONTEND noninteractive

ADD pdns_script.sh /root/
RUN ln -s /dev/null /etc/systemd/system/pdns.service && \
    apt-get update && apt-get install -y pdns-server pdns-backend-mysql

ENTRYPOINT ["/bin/bash", "/root/pdns_script.sh"]

