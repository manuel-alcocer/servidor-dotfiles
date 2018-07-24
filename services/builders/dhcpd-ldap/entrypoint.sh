#!/bin/bash

function infinite_loop(){
    while true; do
        sleep 2
    done
    exit 1
}

function main(){
    if [[ "$DEVEL_MODE" -eq 1 ]]; then
        infinite_loop
    fi
}

main
