#!/bin/bash

# Punto de entrada de SLAPD por:
#   Manuel Alcocer Jiménez <manuel@alcocer.net>
#

# Variables de entorno admitidas:
#
# SI NO EXISTE BBDD o NO SE PASA RESTAURACIÓN:
#       - SUFFIX
#       - ROOTDN
#       - ROOTPW
#       - INIT_DB: Si es establecida se fuerza a la inicialización de
#                   la BBDD en cada arranque del contenedor.
#
# VARIABLES DEL DEMONIO:
#   OPTS: Parámetros adicionales a pasar al comando 'slapd'
#   DEBUG_MODE: entero definiendo el modo de depuración (-d? muestra una lista)
#
# RESTAURAR BASE DE DATOS Y CONFIGURACIÓN:
# - Si existe el fichero "/restore-config.ldif" restaura la configuración
# - Si existe el fichero "/restore-database.ldif" restaura la base de datos
# - VARIABLES PARA RESTAURAR:
#       - RESTORE_CONF_ALWAYS: Si 1, siempre inicializa la configuración
#       - RESTORE_DB_ALWAYS: Si 1, siempre inicializa la BBDD.
#
#       (Por defecto si existe la BBDD no se hace nada con los ficheros)
#
#   NOTAS: Si se pasa alguno de los 2 ficheros nunca se crea la BBDD desde 0

SLAPD_DB_DIR='/etc/openldap/slapd.d'
PID_DIR='/run/openldap'
SLAPD_CONF='/etc/openldap/slapd.conf'
SLAPD_CONF_DIR="$SLAPD_DB_DIR"
DB_DIR='/var/lib/openldap/openldap-data'
DB_CONFIG="${DB_DIR}"'/DB_CONFIG'

# Opciones adicionales
OPTS=""

RESTORE_CONF_FILE='/restore-config.ldif'
RESTORE_DB_FILE='/restore-database.ldif'

function check_dirs(){
    [[ ! -d $PID_DIR ]] && mkdir $PID_DIR
    chown -R ldap:ldap $PID_DIR
    [[ ! -d $SLAPD_DB_DIR ]] && mkdir $SLAPD_DB_DIR
    chown -R ldap:ldap $SLAPD_DB_DIR
}

function check_vars(){
    if [[ -z $SUFFIX || -z $ROOTPW || -z $ROOTDN ]]; then
        printf 'No se puede iniciar la base de datos del LDAP...\n'
        printf 'Faltan: root_pw, rootdn y suffix.\n'
        exit 1
    fi
}

function configure_slapd_conf(){
    [[ -d $SLAPD_DIR ]] && rm -rf ${SLAPD_DIR}/*
    sed -ri 's/^(suffix\s).*$/\1'"${SUFFIX}"'/' $SLAPD_CONF
    sed -ri 's/^(rootpw\s).*$/\1'"${ROOTPW}"'/' $SLAPD_CONF
    sed -ri 's/^(rootdn\s).*$/\1'"${ROOTDN}"'/' $SLAPD_CONF
    sed -ri '/^include.*/a\
include     /etc/openldap/schema/cosine.schema\n\
include     /etc/openldap/schema/inetorgperson.schema\n\
include     /etc/openldap/schema/nis.schema\n\n' $SLAPD_CONF
}

function set_default_db_config(){
    if [[ ! -f $DB_CONFIG ]]; then
        cp ${DB_CONFIG}.example $DB_CONFIG
    fi
}

function populate_db(){
    su - -s /bin/bash ldap \
       -c '/usr/sbin/slaptest -f '"$SLAPD_CONF"' -F '"$SLAPD_DB_DIR"
}

function kill_slapd(){
    retries=5
    counter=0
    slapd_pid=$(pgrep slapd)
    while (( counter < retries )) && (( slapd_pid )); do
        kill $slapd_pid
        slapd_pid=$(pgrep slapd)
        (( counter++ ))
    done
    (( slapd_pid )) && kill -9 $slapd_pid
}

function remove_conf(){
    printf 'Borrando configuración anterior...\n'
    rm -rf $SLAPD_CONF_DIR
    mkdir $SLAPD_CONF_DIR && chown ldap: -R $SLAPD_CONF_DIR
}

function restore_config(){
    conf_lock="$SLAPD_CONF_DIR"'/.slapd_conf.lock'
    [[ $RESTORE_CONF_ALWAYS -eq 1 || ! -f $conf_lock ]] && remove_conf
    if [[ ! -f $conf_lock ]]; then
        printf 'Restaurando directorio de configuración...\n'
        su - -s /bin/bash ldap \
            -c '/usr/sbin/slapadd -n 0 -F '"$SLAPD_CONF_DIR"' -l '"$RESTORE_CONF_FILE"
        (( $? )) || touch $conf_lock
    fi
}

function remove_db(){
    printf 'Borrando base de datos anterior...\n'
    rm -rf $DB_DIR
    mkdir $DB_DIR && chown -R ldap: $DB_DIR
}

function restore_db(){
    db_lock="$DB_DIR"'/.slapd_db.lock'
    [[ $RESTORE_DB_ALWAYS -eq 1 || ! -f $db_lock ]] && remove_db
    if [[ ! -f $db_lock ]]; then
        printf 'Restaurando base de datos...\n'
        su - -s /bin/bash ldap \
            -c '/usr/sbin/slapadd -n 1 -F '"$SLAPD_CONF_DIR"' -l '"$RESTORE_DB_FILE"
        (( $? )) || touch $db_lock
    fi
}

function restore_ldap(){
    if [[ -f $RESTORE_CONF_FILE ]]; then
        restore_config
    fi
    if [[ -f $RESTORE_DB_FILE ]]; then
        restore_db
    fi
}

function init_db(){
    printf 'Comprobación de variables...\n'
    check_vars
    printf 'Configuración de slapd.conf...\n'
    configure_slapd_conf
    printf 'Establece la configuración por defecto...\n'
    set_default_db_config
    printf 'Levantando ldap de forma temporal para poblarlo...\n'
    /usr/sbin/slapd -u ldap -g ldap
    printf 'Poblando ldap...\n'
    populate_db
    printf 'Matando ldap...\n'
    kill_slapd
}

function main(){
    printf 'Comprobación de los directorios..\n'
    check_dirs
    # Si se especifica o si no hay base de datos, se inicializa la BBDD de LDAP
    if [[ -f $RESTORE_DB_FILE || -f $RESTORE_CONF_FILE ]]; then
        restore_ldap
    elif [[ ! -z $INIT_DB || $(ls $SLAPD_DIR | wc -l) -eq 0 ]]; then
        printf 'Iniciación de la base de datos...\n'
        init_db
    fi
}

main

printf 'Lanzando demonio...\n'
/usr/sbin/slapd -u ldap -g ldap -d${DEBUG_MODE:-256} \
    -h "ldapi://%2Frun%2Fopenldap%2Fldapi ldap:///"
    $OPTS

