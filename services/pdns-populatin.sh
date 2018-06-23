#!/usr/bin/env bash

MYSQL_PORT=3306
MYSQL_HOST='127.0.0.1'
MYSQL_USER='root'
MYSQL_PASSWD="${MYSQL_ROOT_PASSWORD:-mariadb}"

MYSQL_CMD="mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWD} -P${MYSQL_PORT}"

PDNS_DB='pdns'
PDNS_USER='pdns'
PDNS_USER_PASSWD='pdns'
PDNS_API_KEY='hackme.123'
PDNS_WEB_PORT=8081
PDNS_WEB_PASSWD='hackme.123'

PDNS_SQL_FILE='/usr/share/doc/pdns-backend-mysql/schema.mysql.sql'

PDNS_CMD='/usr/sbin/pdns_server'

MAX_RETRIES=6
INTERVAL=10

declare DAEMON_OPTS

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

function ping_db(){
    $MYSQL_CMD -e ';' &>/dev/null
    echo $?
}

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

function launch(){
    printf 'Cargando opciones...\n'
    load_options
    printf 'Iniciando el demonio...\n'
    $PDNS_CMD ${DAEMON_OPTS[*]}
}

function main(){
    if [[ $1 == 'populate' ]]; then
        i=0
        while (( i < MAX_RETRIES )); do
            printf 'Haciendo MySQL ping a %s...\n' "${MYSQL_HOST}"
            if [[ $(ping_db) == 0 ]]; then
                populate_mysql
                exit 0
            fi
            sleep $INTERVAL
            ((i++))
        done
        exit 1
    else
        launch
    fi
}

main $1

