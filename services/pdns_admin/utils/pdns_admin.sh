#!/bin/bash

PDNSADMIN_CONF_LOCK='/root/pdns_admin_config.lock'
PDNSADMIN_PATH='/opt/web/powerdns-admin'

function check_config(){
    # si existe este fichero, indica que ya se ha configurado
    # la aplicación Flask
    if [[ -f ${PDNSADMIN_CONF_LOCK} ]]; then
        echo 1
    else
        echo 0
    fi
}

function init_flask(){
    [[ -d  ]]
}

function main(){
    if [[ $(check_config) ]]; then
        init_flask
    fi
}
while true; do
    sleep 10
done
