#!/usr/bin/env bash

COMPOSEFILE=$1

docker system prune
docker rm $(docker ps -aq)
docker image rm $(docker image ls -aq)
docker volume rm $(docker volume ls -q)
docker network prune
