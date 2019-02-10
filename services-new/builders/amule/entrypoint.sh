#!/bin/bash

amule_conf='/var/lib/amule/.aMule/amule.conf'

function configure_ecpassword(){
    ecpassword=$(printf '%s' "$ECPASSWORD" | md5sum | cut -d' ' -f1)
    sed -ri 's/^(ECPassword=).*/\1'"$ecpassword"'/' $amule_conf
}

function configure_webpassword(){
    webpassword=$(printf '%s' "$WEBPASSWORD" | md5sum | cut -d' ' -f1)
    sed -ri 's/^(Password=).*/\1'"$webpassword"'/' $amule_conf
    sed -ri 's/^(Enabled=).*/\11/' $amule_conf
}

function check_lock(){
    if [[ -f /var/lib/amule/.aMule/muleLock ]]; then
        rm -f /var/lib/amule/.aMule/muleLock
    fi
}
function main(){
    configure_ecpassword
    configure_webpassword
    check_lock
    su - -s /bin/sh amule -c 'amuled'
}

main

