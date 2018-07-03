#!/bin/bash

PDNSADMIN_CONF_LOCK='/root/pdns_admin_config.lock'
PDNSADMIN_PATH='/opt/web/powerdns-admin'
VENV_ACTIVATE="${PDNSADMIN_PATH}/flask/bin/activate"

MYSQL_CMD="mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_ROOT_PASSWORD} -P${MYSQL_PORT}"

function exit_on_err(){
    printf 'error en el script..\n'
    while true; do
        sleep 1
        :
    done
    exit 1
}

function flask_db_init(){
    printf 'Flask db init...\n'
    flask db init
    (( $? )) && exit_on_err
}

function flask_db_migrate(){
    printf 'Flask db migrate...\n'
    flask db migrate -m "Init DB"
    (( $? )) && exit_on_err
}

function flask_db_upgrade(){
    printf 'Flask db upgrade...\n'
    flask db upgrade
    (( $? )) && exit_on_err
}

function init_data(){
    printf 'Init data py...\n'
    ./init_data.py
    (( $? )) && exit_on_err
}

function yarn_install(){
    printf 'yarn install...\n'
    yarn install --pure-lockfile
    (( $? )) && exit_on_err
}

function build_assets(){
    printf 'build assets...\n'
    flask assets build
    (( $? )) && exit_on_err
}

function prepare_files(){
    cp -a /root/utils/config.py /opt/web/powerdns-admin
    cp -ar /root/utils /opt/web/powerdns-admin/utils
    cp -a /root/utils/powerdnsadmin.wsgi /opt/web/powerdns-admin
}

function ping_mysql(){
    $MYSQL_CMD -e ';'
    (( $? )) && exit_on_err
}

function ping_db(){
    $MYSQL_CMD -e "use $SQLA_DB_NAME"
    if (( $? )); then
        printf 'La base de datos no existe.\n'
    else
        printf 'La base de datos existe. Borrándola..\n'
        $MYSQL_CMD -e "drop database ${SQLA_DB_NAME}"
    fi
}

function db_creation(){
    printf 'Creando la base de datos...\n'
    $MYSQL_CMD -e "create database $SQLA_DB_NAME"
    (( $? )) && printf 'No se pudo crear la base de datos.\nSaliendo...\n' && exit_on_err
}

function create_user(){
    printf 'Creando usuario..\n'
    $MYSQL_CMD -e "create user '${SQLA_DB_USER}'@'%' identified by '${SQLA_DB_PASSWORD}'"
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

function check_user_name(){
    printf 'Comprobando usuario...\n'
    username=$($MYSQL_CMD -BNe "select user from mysql.user where user like '${SQLA_DB_USER}%'")
    (( $? )) && printf 'Error inesperado.\nSaliendo...\n' && exit_on_err
    if [[ $username != $SQLA_DB_USER ]]; then
        create_user
    else
        check_user_password
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
    check_user_name
    check_user_password
    check_grants
}

function database_init(){
    printf 'Instalando paquetes necesarios...\n'
    apk --update add --no-cache mariadb-client
    printf 'Haciendo ping a mysql...\n'
    ping_mysql
    printf 'Haciendo ping a la base de datos...\n'
    ping_db
    printf 'Creando la base de datos..\n'
    db_creation
    printf 'Inicialización del usuario...\n'
    userdb_init
    printf 'Eliminando paquetes innecesarios...\n'
    apk --update del --no-cache mariadb-client
}

function flask_init(){
    [[ -d 'migrations' ]] && rm -rf migrations
    prepare_files
    flask_db_init
    flask_db_migrate
    flask_db_upgrade
    init_data
    yarn_install
    build_assets
}

function main(){
    source ${VENV_ACTIVATE}
    cd ${PDNSADMIN_PATH}
    if [[ ! -f ${PDNSADMIN_CONF_LOCK} ]]; then
        database_init
        flask_init
        touch ${PDNSADMIN_CONF_LOCK}
    fi
    printf 'Script finalizado correctamente...\n'
}

main

printf 'Lanzando demonio...\n'

uwsgi --plugin /usr/lib/uwsgi/python3_plugin.so \
    --http-socket 0.0.0.0:9191 \
    --wsgi-file /opt/web/powerdns-admin/powerdnsadmin.wsgi \
    --enable-threads \
    --venv /opt/web/powerdns-admin/flask/
