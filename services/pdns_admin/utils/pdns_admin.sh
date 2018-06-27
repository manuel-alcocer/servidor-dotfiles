#!/bin/bash

PDNSADMIN_CONF_LOCK='/root/pdns_admin_config.lock'
PDNSADMIN_PATH='/opt/web/powerdns-admin'
VENV_ACTIVATE="${PDNSADMIN_PATH}/flask/bin/activate"

MYSQL_CMD="mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_ROOT_PASSWORD} -P${MYSQL_PORT}"

function exit_on_err(){
    # exit 1
    while true; do
        sleep 10
        :
    done
}

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
    (( $? )) && exit 1
}

function flask_db_migrate(){
    flask db migrate -m "Init DB"
    (( $? )) && exit 1
}

function flask_db_upgrade(){
    flask db upgrade
    (( $? )) && exit 1
}

function init_data(){
    ./init_data.py
    (( $? )) && exit 1
}

function yarn_install(){
    yarn install --pure-lockfile
    (( $? )) && exit 1
}

function build_assets(){
    flask assets build
    (( $? )) && exit 1
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

function ping_mysql(){
    $MYSQL_CMD -e ';'
    (( $? )) && exit_on_err
}

function check_db(){
    $MYSQL_CMD -e "use $SQLA_DB_NAME"
    echo $?
}

function db_creation(){
    printf 'Haciendo ping a mysql...\n'
    ping_mysql
    printf 'Haciendo ping a la base de datos...\n'
    if [[ $(check_db) == 0 ]]; then
        printf 'La base de datos existe. No se crea\n'
    else
        printf 'Creando la base de datos...\n'
        $MYSQL_CMD -e "create database $SQLA_DB_NAME"
        (( $? )) && printf 'No se pudo crear la base de datos.\nSaliendo...\n' && exit_on_err
    fi
}

function create_user(){
    printf 'Creando usuario..\n'
    $MYSQL_CMD -e "create user ${SQLA_DB_USER}@'%' identified by '${SQLA_DB_PASSWORD}'"
    (( $? )) && printf 'No se pudo crear el usuario.\nSaliendo...\n' && exit_on_err
}

function check_user_password(){
    printf 'Comprobando credenciales de acceso...\n'
    mysql -h${SQLA_DB_HOST} -u${SQLA_DB_USER} -p${SQLA_DB_PASSWORD} -P${MYSQL_PORT} -e ';'
    if (( $? )); then
        create_user
    else
        printf 'El usuario ya existe y tiene password. No hay que crearlo\n'
    fi
}

function check_username(){
    printf 'Comprobando usuario...\n'
    username=$($MYSQL_CMD -BNe "select user from mysql.user where user like '${SQLA_DB_USER}%'")
    result=$?
    if [[ $result == 0 ]] && [[ $username != $SQLA_DB_USER ]]; then
        create_user
    elif [[ $result == 0 ]]; then
        check_user_password
    else
        printf 'Error inesperado.\nSaliendo...\n'
        exit_on_err
    fi
}

function grant_user(){
    printf 'Asignando privilegios...\n'
    $MYSQL_CMD -e "grant all on ${SQLA_DB_NAME}.* to '${SQLA_DB_USER}'@'%'"
    (( $? )) && printf 'No se pudieron asignar privilegios.\nSaliendo...\n' && exit_on_err
}

function check_grants(){
    printf 'Comprobando privilegios...\n'
    mysql -h${SQLA_DB_HOST} -u${SQLA_DB_USER} -p${SQLA_DB_PASSWORD} -P${MYSQL_PORT} -e "use $SQLA_DB_NAME"
    if (( $? )); then
       grant_user
    else
        printf 'privilegios correctos...\n'
    fi
}

function userdb_init(){
    check_username
    check_user_password
    check_grants
}

function database_init(){
    db_creation
    userdb_init
}

function main(){
    if [[ $(check_config) ]]; then
        #source ${VENV_ACTIVATE}
        database_init
        #init_flask
        touch ${PDNSADMIN_CONF_LOCK}
    fi
}

main
