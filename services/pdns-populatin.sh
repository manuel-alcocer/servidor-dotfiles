#!/usr/bin/env bash

MYSQL_PORT=3306
MYSQL_HOST='mariadb'
MYSQL_USER='root'
MYSQL_PASSWD="$MYSQL_ROOT_PASSWORD"

MYSQL_CMD="mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWD} -P${MYSQL_PORT}"

PDNS_DB='pdns'
PDNS_USER='pdns'
PDNS_USER_PASSWD='pdns'

PDNS_SQL_FILE='/usr/share/doc/pdns-backend-mysql/schema.mysql.sql'

function create_pdns_db(){
    ARGS="-e 'create database $PDNS_DB'"
    $MYSQL_CMD $ARGS
}

function create_pdns_user(){
    ARGS="-e 'create user ${PDNS_USER}@%'"
}

function populate-mysql(){
    create_pdns_db
    create_pdns_user
}
