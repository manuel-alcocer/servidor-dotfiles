#!/bin/bash

MYSQL_CMD="mysql -h${MYSQL_HOST:-mariadb} -u${PDNS_USER:-pdns} -p${PDNS_USER_PASSWD:-pdns} -P${MYSQL_PORT:-3306}"

PDNS_SQL_FILE='/usr/share/doc/pdns/schema.mysql.sql'

PDNS_CMD='/usr/sbin/pdns_server'

# si MAX_RETRIES < 1: espera infinito hasta que haya conexión

MAX_RETRIES=10
INTERVAL=10

function dump_db(){
    $MYSQL_CMD "${PDNS_DB}" <${PDNS_SQL_FILE}
}

function populate_mysql(){
    printf 'Inicialización de la base de datos de PowerDNS...\n'
    if [[ -f "${PDNS_SQL_FILE}" ]]; then
        printf 'Poblando la base de datos...\n'
        dump_db
    fi
}

function ping_mysql(){
    $MYSQL_CMD -e ';' &>/dev/null
    return $?
}

function ping_db(){
    $MYSQL_CMD -e "select * from ${PDNS_DB}.records" &>/dev/null
    return $?
}

function launch(){
    printf 'Iniciando el demonio...\n'
    export DAEMON_OPTS=$(echo $DAEMON_OPTS | envsubst)
    $PDNS_CMD $DAEMON_OPTS
}

function main(){
    i=0
    printf 'Haciendo MySQL ping a %s...\n' "${MYSQL_HOST}"
    while (( i < MAX_RETRIES )) && ! $(ping_mysql); do
        (( MAX_RETRIES > 0 )) && ((i++))
        printf '[%s] Intentando de nuevo en %s segundos...\n' "$i" "${INTERVAL}"
        sleep $INTERVAL
    done
    if ! $(ping_mysql); then
        printf 'No hay conexión con el servicio de base de datos.\nSaliendo...\n'
        exit 1
    else
        printf 'Hay conexión a MySQL...\n'
        printf 'Haciendo ping a la base de datos de PowerDNS...\n'
        ! ping_db && populate_mysql
    fi
    [[ $1 == 'start' ]] && launch
}

main $1
