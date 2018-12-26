#!/bin/bash

MYSQL_CMD="mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_ROOT_PASSWORD} -P${MYSQL_PORT}"

PDNS_SQL_FILE='/usr/share/doc/pdns/schema.mysql.sql'

PDNS_CMD='/usr/sbin/pdns_server'

# si MAX_RETRIES < 1: espera infinito hasta que haya conexión

MAX_RETRIES=10
INTERVAL=10

declare DAEMON_OPTS

function load_options(){
    DAEMON_OPTS=(
        "--allow-recursion=0.0.0.0/0"
        "--api=yes"
        "--api-key=${PDNS_API_KEY}"
        "--daemon=no"
        "--disable-syslog"
        "--dnsupdate=yes"
        "--guardian=no"
        "--gmysql-dbname=${PDNS_DB}"
        "--gmysql-dnssec=yes"
        "--gmysql-host=${MYSQL_HOST}"
        "--gmysql-password=${PDNS_USER_PASSWD}"
        "--gmysql-port=${MYSQL_PORT}"
        "--gmysql-user=${PDNS_USER}"
        "--launch=gmysql"
        "--local-address=0.0.0.0"
        "--local-ipv6="
        "--no-config"
        "--security-poll-suffix="
        "--setgid=pdns"
        "--setuid=pdns"
        "--webserver=yes"
        "--webserver-address=0.0.0.0"
        "--webserver-allow-from=0.0.0.0/0,::/0"
        "--webserver-password=${PDNS_WEB_PASSWD}"
        "--webserver-port=${PDNS_WEB_PORT}"
        "--write-pid=no")
}

function create_pdns_db(){
    $MYSQL_CMD -e "create database ${PDNS_DB} collate 'utf8_unicode_ci'"
    (( $? )) && printf 'No se puede crear la base de datos.\nSaliendo...\n' && \
        exit 1
}

function create_pdns_user(){
    $MYSQL_CMD -e "create user '${PDNS_USER}'@'%' identified by '${PDNS_USER_PASSWD}'"
}

function grant_privileges(){
    $MYSQL_CMD -e "grant all on ${PDNS_DB}.* to '${PDNS_USER}'@'%'"
}

function dump_db(){
    $MYSQL_CMD "${PDNS_DB}" <${PDNS_SQL_FILE}
}

function populate_mysql(){
    printf 'Inicialización de la base de datos de PowerDNS...\n'
    if [[ -f "${PDNS_SQL_FILE}" ]]; then
        printf 'Creando la base de datos %s...\n' "${PDNS_DB}"
        create_pdns_db
        printf 'Creando el usuario %s...\n' "${PDNS_USER}"
        create_pdns_user
        printf 'Dando privilegios a %s sobre %s...\n' "${PDNS_USER}" "${PDNS_DB}"
        grant_privileges
        printf 'Poblando la base de datos...\n'
        dump_db
    fi
}

function ping_mysql(){
    $MYSQL_CMD -e ';' &>/dev/null
    return $?
}

function ping_db(){
    $MYSQL_CMD -e "use ${PDNS_DB}" &>/dev/null
    return $?
}

function launch(){
    printf 'Cargando opciones...\n'
    load_options
    printf 'Iniciando el demonio...\n'
    $PDNS_CMD ${DAEMON_OPTS[*]}
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
