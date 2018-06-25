#!/bin/bash

PDNSADMIN_CONF_LOCK='/root/pdns_admin_config.lock'
PDNSADMIN_PATH='/opt/web/powerdns-admin'
VENV_ACTIVATE="${PDNSADMIN_PATH}/flask/bin/activate"

MYSQL_CMD="mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_ROOT_PASSWORD} -P${MYSQL_PORT}"

function check_config(){
    # si existe este fichero, indica que ya se ha configurado
    # la aplicación Flask
    if [[ -f ${PDNSADMIN_CONF_LOCK} ]]; then
        echo 1
    else
        echo 0
    fi
}

function flask_db_init(){
    flask db init
    [[ $? ]] && exit 1
}

function flask_db_migrate(){
    flask db migrate -m "Init DB"
    [[ $? ]] && exit 1
}

function flask_db_upgrade(){
    flask db upgrade
    [[ $? ]] && exit 1
}

function init_data(){
    ./init_data.py
    [[ $? ]] && exit 1
}

function yarn_install(){
    yarn install --pure-lockfile
    [[ $? ]] && exit 1
}

function build_assets(){
    flask assets build
    [[ $? ]] && exit 1
}

function init_flask(){
    cd ${PDNSADMIN_PATH}
    [[ -d 'migrations' ]] && rm -rf migrations
    export FLASK_APP=app/__init__.py
    flask_db_init
    flask_db_migrate
    init_data
    yarn_install
    build_assets
}

function database_init(){
    $MYSQL_CMD -e "create database $SQLA_DB_NAME"
    [[ $? ]] && printf 'No se pudo crear la base de datos.\nSaliendo...\n' && exit 1
    $MYSQL_CMD -e "create user '${SQLA_DB_USER}'@'%' identified by '${SQLA_DB_PASSWORD}'"
    [[ $? ]] && printf 'No se pudo crear el usuario.\nSaliendo...\n' && exit 1
    $MYSQL_CMD -e "grant all on ${SQLA_DB_NAME}.* to '${SQLA_DB_USER}'@'%'"
    [[ $? ]] && printf 'No se pudieron asignar privilegios.\nSaliendo...\n' && exit 1
}

function main(){
    if [[ $(check_config) ]]; then
        source ${VENV_ACTIVATE}
        database_init
        init_flask
        touch ${PDNSADMIN_CONF_LOCK}
    fi
    while true; do
        sleep 10
        :
    done
}

main
