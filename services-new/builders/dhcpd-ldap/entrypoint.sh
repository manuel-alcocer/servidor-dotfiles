#!/bin/bash

# Variables del contenedor:
# =========================
#
# INTERFACES: string con las interfaces en las que levantar
#             DHCPD separadas por espacios (DEFAULT: eth0)
# RECONF: Si 1, reconfigura en cada inicio del contenedor con las variables
#         del entorno

DHCPD_CONF=/etc/dhcp/dhcpd.conf
DHCPD_HOME=/var/lib/dhcp
LEASE_FILE=${DHCPD_HOME}/dhcpd.leases

function infinite_loop(){
    while true; do
        sleep 1
    done
    exit 1
}

function generate_config(){
    cat <<-EOF > $DHCPD_CONF
	ldap-server "${LDAP_SERVER//\"}";
	ldap-port ${LDAP_PORT//\"};
	ldap-username "${LDAP_USERNAME//\"}";
	ldap-password "${LDAP_PASSWORD//\"}";
	ldap-base-dn "${LDAP_BASE_DN//\"}";
	ldap-method ${LDAP_METHOD//\"};
	ldap-debug-file "${LDAP_DEBUG_FILE//\"}";
	EOF
}

function check_dirs(){
    [[ ! -d $DHCPD_HOME ]] && mkdir -p $DHCPD_HOME
    [[ ! -f $LEASE_FILE ]] && touch $LEASE_FILE
}

function main(){
    if [[ ! -f $DHCPD_CONF ]] || [[ $RECONF -eq 1 ]]; then
        generate_config
    fi
    check_dirs
    if [[ "$DEVEL_MODE" -eq 1 ]]; then
        printf 'Modo desarrollo..\n\n'
        infinite_loop
    fi
}

main
