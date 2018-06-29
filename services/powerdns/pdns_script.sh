#!/usr/bin/env bash

MYSQL_CMD="mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_ROOT_PASSWORD} -P${MYSQL_PORT}"

PDNS_SQL_FILE='/usr/share/doc/pdns-backend-mysql/schema.mysql.sql'

PDNS_CMD='/usr/sbin/pdns_server'

# si MAX_RETRIES < 1: espera infinito hasta que haya conexión

MAX_RETRIES=5
INTERVAL=2

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
    printf 'Creando la base de datos %s...\n' "${PDNS_DB}"
    $MYSQL_CMD -e "create database ${PDNS_DB}"
    if [[ $? != 0 ]]; then
        printf 'No se puede crear la base de datos.\nSaliendo...\n'
        exit 1
    fi
}

function create_pdns_user(){
    printf 'Creando el usuario %s...\n' "${PDNS_USER}"
    $MYSQL_CMD -e "create user '${PDNS_USER}'@'%' identified by '${PDNS_USER_PASSWD}'"
}

function grant_privileges(){
    printf 'Dando privilegios a %s sobre %s...\n' "${PDNS_USER}" "${PDNS_DB}"
    $MYSQL_CMD -e "grant all on ${PDNS_DB}.* to '${PDNS_USER}'@'%'"
}

function dump_db(){
    printf 'Poblando la base de datos...\n'
    $MYSQL_CMD "${PDNS_DB}" <${PDNS_SQL_FILE}
}

function populate_mysql(){
    if [[ -f "${PDNS_SQL_FILE}" ]]; then
        create_pdns_db
        create_pdns_user
        grant_privileges
        dump_db
    fi
}

function ping_mysql(){
    printf 'Haciendo MySQL ping a %s...\n' "${MYSQL_HOST}"
    $MYSQL_CMD -e ';' &>/dev/null
    return $?
}

function ping_db(){
    $MYSQL_CMD -e "use ${PDNS_DB}" &>/dev/null
    echo $?
}

function launch(){
    printf 'Cargando opciones...\n'
    load_options
    printf 'Iniciando el demonio...\n'
    set -x
    $PDNS_CMD ${DAEMON_OPTS[*]}
    set +x
}

function main(){
    i=0
    ping_mysql
    pinged=$?
    while (( i < MAX_RETRIES )) && (( pinged != 0 )); do
        (( MAX_RETRIES > 0 )) && ((i++))
        printf '[%s] Intentando de nuevo en %s segundos...\n' "$i" "${INTERVAL}"
        sleep $INTERVAL
        ping_mysql
        pinged=$?
    done
    if (( pinged == 0 )); then
        [[ $(ping_db) == 0 ]] || populate_mysql
        launch
    else
        printf 'No hay conexión con el servicio de base de datos.\nSaliendo...\n'
        exit 1
    fi
}

main $1

