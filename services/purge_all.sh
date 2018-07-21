#!/usr/bin/env bash

COMPOSEFILE=$1

if [[ ! -z $COMPOSEFILE ]]; then
    [[ -f $COMPOSEFILE ]] && ARGS="-f $COMPOSEFILE" || exit 1
fi

docker-compose $ARGS stop
docker rm $(docker-compose $ARGS ps -q)
docker images rm $(docker-compose $ARGS images -q)
docker volume rm $(docker volume ls -q)
docker network prune
