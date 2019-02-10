#!/bin/bash

# Versión del script para PowerDNS Admin en SQLite
#


PDNSADMIN_PATH='/opt/web/powerdns-admin'
PDNSADMIN_CONF_LOCK="${PDNSADMIN_PATH}/pdns_admin_config.lock"
VENV_ACTIVATE="${PDNSADMIN_PATH}/flask/bin/activate"

function exit_on_err(){
    printf 'error en el script..\n'
    while true; do
        printf 'error en el script...\n'
        sleep 2
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

function flask_init(){
    [[ -d 'migrations' ]] && rm -rf migrations
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
        cp /opt/web/daemon/config.py ${PDNSADMIN_PATH}
        flask_init
        touch ${PDNSADMIN_CONF_LOCK}
        printf 'Ajustando propietario...\n' >&2
        chown -R 10000:10000 ${PDNSADMIN_PATH}
    fi
    printf 'Script finalizado correctamente...\n'
}

main

if [[ $1 == 'start' ]]; then
    printf 'Lanzando demonio...\n'

    uwsgi --plugin /usr/lib/uwsgi/python3_plugin.so \
        --http-socket 0.0.0.0:${PDNSADMIN_PORT} \
        --wsgi-file /opt/web/daemon/powerdnsadmin.wsgi \
        --enable-threads \
        --venv /opt/web/powerdns-admin/flask/ \
        --uid 10000 --gid 10000

fi
